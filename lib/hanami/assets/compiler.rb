require 'set'
require 'find'
require 'hanami/utils/class_attribute'

module Hanami
  module Assets
    # Missing Asset error
    class MissingAsset < Error
      def initialize(name, sources)
        sources = sources.map(&:to_s).join(', ')
        super("Missing asset: `#{name}' (sources: #{sources})")
      end
    end

    # Unknown Asset Engine error
    class UnknownAssetEngine < Error
      def initialize(source)
        super("No asset engine registered for `#{::File.basename(source)}'")
      end
    end

    # Assets compiler
    #
    # It compiles assets that needs to be preprocessed (eg. Sass or ES6) into
    # the destination directory.
    #
    # Vanilla javascripts or stylesheets are just copied over.
    #
    # @since 0.1.0
    # @api private
    class Compiler # rubocop:disable Metrics/ClassLength
      # @since 0.1.0
      # @api private
      DEFAULT_PERMISSIONS = 0o644

      # @since 0.1.0
      # @api private
      COMPILE_PATTERN = '*.*.*'.freeze # Example hello.js.es6

      # @since 0.1.0
      # @api private
      EXTENSIONS = { '.js' => true, '.css' => true, '.map' => true }.freeze

      include Utils::ClassAttribute

      # @since 0.3.0
      # @api private
      class_attribute :subclasses
      self.subclasses = Set.new

      # @since 0.3.0
      # @api private
      def self.inherited(subclass)
        super
        subclasses.add(subclass)
      end

      # Compile the given asset
      #
      # @param configuration [Hanami::Assets::Configuration] the application
      #   configuration associated with the given asset
      #
      # @param name [String] the asset path
      #
      # @since 0.1.0
      # @api private
      def self.compile(configuration, name)
        return unless configuration.compile

        require 'tilt'
        require 'hanami/assets/cache'
        require 'hanami/assets/compilers/sass'
        require 'hanami/assets/compilers/less'
        fabricate(configuration, name).compile
      end

      # @since 0.3.0
      # @api private
      def self.fabricate(configuration, name)
        source = configuration.source(name)
        engine = (subclasses + [self]).find do |klass|
          klass.eligible?(source)
        end

        engine.new(configuration, name)
      end

      # @since 0.3.0
      # @api private
      def self.eligible?(_name)
        true
      end

      # Assets cache
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Cache
      def self.cache
        @@cache ||= Assets::Cache.new # rubocop:disable Style/ClassVars
      end

      # Return a new instance
      #
      # @param configuration [Hanami::Assets::Configuration] the application
      #   configuration associated with the given asset
      #
      # @param name [String] the asset path
      #
      # @return [Hanami::Assets::Compiler] a new instance
      #
      # @since 0.1.0
      # @api private
      def initialize(configuration, name)
        @configuration = configuration
        @name          = Pathname.new(name)
      end

      # Compile the asset
      #
      # @raise [Hanami::Assets::MissingAsset] if the asset can't be found in
      #   sources
      #
      # @since 0.1.0
      # @api private
      def compile
        raise MissingAsset.new(@name, @configuration.sources) unless exist?
        return unless modified?

        if compile?
          compile!
        else
          copy!
        end

        cache!
      end

      private

      # @since 0.1.0
      # @api private
      def source
        @source ||= @configuration.source(@name)
      end

      # @since 0.1.0
      # @api private
      def destination
        @destination ||= @configuration.destination_directory.join(destination_name)
      end

      def relative_destination_name(name: @name, add_prefix: true)
        prefix = @configuration.prefix
        result = name.to_s
        @configuration.base_directories.each do |base_dir|
          if result.start_with?(base_dir)
            path = add_prefix ? prefix.join(base_dir) : base_dir
            result = name.relative_path_from(Pathname.new(path))
            break
          end
        end
        result
      end

      def absolute_destination_name
        result = ::File.basename(@name)
        @configuration.sources.each do |source|
          if @name.to_s.start_with?(source.to_s)
            result = @name.relative_path_from(source)
            break
          end
        end
        relative_destination_name(name: Pathname.new(result), add_prefix: false)
      end

      # @since 0.1.0
      # @api private
      def destination_name
        result = @name.relative? ? relative_destination_name : absolute_destination_name
        result = result.to_s

        if compile?
          result.scan(/\A[[[:alnum:]][\-\_]]*\.[[\w]]*/).first || result
        else
          result
        end
      end

      # @since 0.1.0
      # @api private
      def exist?
        !source.nil? &&
          source.exist?
      end

      # @since 0.3.0
      # @api private
      def modified?
        !destination.exist? ||
          cache.modified?(source)
      end

      # @since 0.1.0
      # @api private
      def compile?
        @compile ||= ::File.fnmatch(COMPILE_PATTERN, ::File.basename(source.to_s)) &&
                     !EXTENSIONS[::File.extname(source.to_s)]
      end

      # @since 0.1.0
      # @api private
      def compile!
        write { renderer.render }
      rescue RuntimeError
        raise UnknownAssetEngine.new(source)
      end

      # @since 0.1.0
      # @api private
      def copy!
        write { source.read }
      end

      # @since 0.1.0
      # @api private
      def cache!
        cache.store(source, dependencies)
      end

      # @since 0.1.0
      # @api private
      def write
        destination.dirname.mkpath
        destination.open(File::WRONLY | File::TRUNC | File::CREAT, DEFAULT_PERMISSIONS) do |file|
          file.write(yield)
        end
      end

      # @since 0.1.0
      # @api private
      def cache
        self.class.cache
      end

      # @since 0.3.0
      # @api private
      def renderer
        Tilt.new(source)
      end

      # @since 0.3.0
      # @api private
      def dependencies
        nil
      end

      # @since 0.3.0
      # @api private
      def load_paths
        result = []

        @configuration.sources.each do |source|
          Find.find(source) do |path|
            result << path if File.directory?(path)
          end
        end

        result
      end
    end
  end
end
