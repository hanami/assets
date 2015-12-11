module Lotus
  module Assets
    class MissingAsset < ::StandardError
      def initialize(name, sources)
        sources = sources.map(&:to_s).join(', ')
        super("Missing asset: `#{ name }' (sources: #{ sources })")
      end
    end

    class UnknownAssetEngine < ::StandardError
      def initialize(source)
        super("No asset engine registered for `#{ ::File.basename(source) }'")
      end
    end

    # @api private
    class Compiler
      DEFAULT_PERMISSIONS = 0644

      COMPILE_PATTERN = '*.*.*'.freeze # Example hello.js.es6

      SASS_CACHE_LOCATION = Pathname(Lotus.respond_to?(:root) ?
                                     Lotus.root : Dir.pwd).join('tmp', 'sass-cache')


      def self.compile(configuration, name)
        return unless configuration.compile

        require 'tilt'
        require 'lotus/assets/cache'
        new(configuration, name).compile
      end

      def self.cache
        @@cache ||= Assets::Cache.new
      end

      def initialize(configuration, name)
        @configuration = configuration
        @name          = Pathname.new(name)
      end

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
      def source
        @source ||= begin
          @name.absolute? ? @name :
            @configuration.find(@name)
        end
      end

      # FIXME this has a really poor perf
      def destination
        @destination ||= begin
          Pathname.new(Utils::PathPrefix.new(@configuration.destination).join(@configuration.prefix.to_s, basename)).tap do |dest|
            dest.dirname.mkpath
          end
        end
      end

      def basename
        result = ::File.basename(@name)
        result.scan(/\A[[[:alnum:]][\-\_]]*\.[[\w]]*/).first || result
      end

      def exist?
        !source.nil? &&
          source.exist?
      end

      def fresh?
        !destination.exist? ||
          cache.fresh?(source)
      end

      def compile?
        ::File.fnmatch(COMPILE_PATTERN, source.to_s)
      end

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
        write { Tilt.new(source, nil, load_paths: @configuration.sources.to_a, cache_location: sass_cache_location).render }
      rescue RuntimeError
        raise UnknownAssetEngine.new(source)
      end

      def copy!
        write { source.read }
      end

      def cache!
        cache.store(source)
      end

      def write
        destination.open(File::WRONLY|File::CREAT, DEFAULT_PERMISSIONS) do |file|
          file.write(yield)
        end
      end

      def cache
        self.class.cache
      end

      def sass_cache_location
        SASS_CACHE_LOCATION
      end
    end
  end
end
