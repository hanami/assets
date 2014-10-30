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
      def self.compile(configuration, type, name)
        return unless configuration.compile

        require 'fileutils'
        require 'tilt'
        new(configuration, type, name).compile
      end

      def initialize(configuration, type, name)
        @configuration = configuration
        @definition    = @configuration.asset(type)
        @name          = name
      end

      def compile
        # FIXME in initializer make: @name = name + @definition.ext
        raise MissingAsset.new(@name + @definition.ext, @definition.sources) unless exist?

        if compile?
          compile!
        else
          copy!
        end
      end

      private
      def source
        @source ||= @definition.sources.find("#{ @name }#{ @definition.ext }")
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

      def compile?
        source.extname != @definition.ext
      end

      def compile!
        # TODO File::WRONLY|File::CREAT
        destination.open('w') {|file| file.write(Tilt.new(source).render) }
      rescue RuntimeError
        raise UnknownAssetEngine.new(source)
      end

      def copy!
        FileUtils.copy(source, destination)
      end
    end
  end
end
