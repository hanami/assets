module Lotus
  module Assets
    # @api private
    class Compiler
      def self.compile(configuration, type, name)
        # FIXME return unless configuration.compile

        require 'fileutils'
        require 'tilt'
        new(configuration, type, name).compile
      end

      def initialize(configuration, type, name)
        @configuration = configuration
        @definition    = @configuration.asset(type)
        @source        = @definition.find(name) # FIXME move #find in this class
        @name          = name
      end

      def compile
        return unless exist?

        # TODO extract into #destination
        dest = @configuration.destination.join(@definition.relative_path(@name))
        dest.dirname.mkpath

        if compile?
          # TODO File::WRONLY|File::CREAT
          dest.open('w') {|file| file.write(Tilt.new(@source).render) }
        else
          FileUtils.copy(@source, dest)
        end
      end

      private
      def exist?
        !@source.nil?
      end

      def compile?
        !@source.match(/#{ @definition.ext }\z/)
      end
    end
  end
end
