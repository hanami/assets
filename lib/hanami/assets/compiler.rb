require 'find'

module Hanami
  module Assets
    class MissingAsset < Error
      def initialize(name, sources)
        sources = sources.map(&:to_s).join(', ')
        super("Missing asset: `#{ name }' (sources: #{ sources })")
      end
    end

    class UnknownAssetEngine < Error
      def initialize(source)
        super("No asset engine registered for `#{ ::File.basename(source) }'")
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
    class Compiler
      # @since 0.1.0
      # @api private
      DEFAULT_PERMISSIONS = 0644

      # @since 0.1.0
      # @api private
      COMPILE_PATTERN = '*.*.*'.freeze # Example hello.js.es6

      # @since 0.1.0
      # @api private
      EXTENSIONS = {'.js' => true, '.css' => true, '.map' => true}.freeze

      # @since 0.1.0
      # @api private
      SASS_CACHE_LOCATION = Pathname(Hanami.respond_to?(:root) ?
                                     Hanami.root : Dir.pwd).join('tmp', 'sass-cache')

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
        new(configuration, name).compile
      end

      # Assets cache
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Cache
      def self.cache
        @@cache ||= Assets::Cache.new
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
        return unless fresh?

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
        @source ||= begin
          @name.absolute? ? @name :
            @configuration.find(@name)
        end
      end

      # @since 0.1.0
      # @api private
      def destination
        @destination ||= @configuration.destination_directory.join(basename)
      end

      # @since 0.1.0
      # @api private
      def basename
        result = ::File.basename(@name)

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

      # @since 0.1.0
      # @api private
      def fresh?
        !destination.exist? ||
          cache.fresh?(source)
      end

      # @since 0.1.0
      # @api private
      def compile?
        @compile ||= ::File.fnmatch(COMPILE_PATTERN, source.to_s) &&
          !EXTENSIONS[::File.extname(source.to_s)]
      end

      # @since 0.1.0
      # @api private
      def compile!
        # NOTE `:load_paths' is useful only for Sass engine, to make `@include' directive to work.
        # For now we don't want to maintan a specialized Compiler version for Sass.
        #
        # If in the future other precompilers will need special treatment,
        # we can consider to maintain several specialized versions in order to
        # don't add a perf tax to all the other preprocessors who "just work".
        #
        # Example: if Less "just works", we can keep it in the general `Compiler',
        # but have a `SassCompiler` if it requires more than `:load_paths'.
        #
        # NOTE: We need another option to pass for Sass: `:cache_location'.
        #
        # This is needed to don't create a `.sass-cache' directory at the root of the project,
        # but to have it under `tmp/sass-cache'.
        write { Tilt.new(source, nil, load_paths: sass_load_paths, cache_location: sass_cache_location).render }
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
        cache.store(source)
      end

      # @since 0.1.0
      # @api private
      def write
        destination.dirname.mkpath
        destination.open(File::WRONLY|File::TRUNC|File::CREAT, DEFAULT_PERMISSIONS) do |file|
          file.write(yield)
        end
      end

      # @since 0.1.0
      # @api private
      def cache
        self.class.cache
      end

      # @since x.x.x
      # @api private
      def sass_load_paths
        result = []

        @configuration.sources.each do |source|
          Find.find(source) do |path|
            result << path if File.directory?(path)
          end
        end

        result
      end

      # @since 0.1.0
      # @api private
      def sass_cache_location
        SASS_CACHE_LOCATION
      end
    end
  end
end
