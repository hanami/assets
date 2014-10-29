module Lotus
  module Assets
    class MissingAsset < ::StandardError
      def initialize(name, sources)
        sources = sources.map(&:to_s).join(', ')
        super("Missing asset: `#{ name }' (sources: #{ sources })")
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
          # TODO File::WRONLY|File::CREAT
          # FIXME create custom exception in case of missing Tilt engine
          destination.open('w') {|file| file.write(Tilt.new(source).render) }
        else
          FileUtils.copy(source, destination)
        end
      end

      private
      def source
        @source ||= begin
          # FIXME only load "#{ @name }#{ @definition.ext }.*"
          name = "#{ @name }.*"

          # FIXME this is really unefficient
          @definition.sources.each do |load_path|
            path = Pathname.glob(load_path.join(name)).first
            return path.to_s unless path.nil?
          end

          nil
        end
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
        !source.match(/#{ @definition.ext }\z/)
      end
    end
  end
end
