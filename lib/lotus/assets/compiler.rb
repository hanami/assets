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

      def self.compile(configuration, type, name)
        return unless configuration.compile

        require 'tilt'
        require 'lotus/assets/cache'
        new(configuration, type, name).compile
      end

      def self.cache
        @@cache ||= Assets::Cache.new
      end

      def initialize(configuration, type, name)
        @configuration = configuration
        @definition    = @configuration.asset(type)
        @name          = name + @definition.ext
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
        @source ||= @configuration.find(@name)
      end

      def destination
        @destination ||= begin
          @configuration.destination.join(@definition.relative_path(@name)).tap do |dest|
            dest.dirname.mkpath
          end
        end
      end

      def exist?
        !source.nil?
      end

      def fresh?
        !destination.exist? ||
          cache.fresh?(source)
      end

      def compile?
        source.extname != @definition.ext
      end

      def compile!
        write { Tilt.new(source).render }
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
    end
  end
end
