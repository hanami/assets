require 'lotus/assets/compiler'

module Lotus
  module Assets
    class Precompiler
      def initialize(configuration, duplicates)
        @configuration = configuration
        @duplicates    = duplicates
      end

      def run
        clear_public_directory
        precompile
      end

      private

      def clear_public_directory
        public_directory = Lotus::Assets.configuration.public_directory
        public_directory.rmtree if public_directory.exist?
      end

      def precompile
        applications.each do |duplicate|
          config = duplicate.configuration
          config.compile true

          config.files.each do |file|
            Compiler.compile(config, file)
          end
        end
      end

      def applications
        @duplicates.empty? ?
          [Lotus::Assets] : @duplicates
      end
    end
  end
end
