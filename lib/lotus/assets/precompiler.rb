require 'lotus/assets/compiler'

module Lotus
  module Assets
    class Precompiler
      def initialize(configuration, duplicates)
        @configuration = configuration
        @duplicates    = duplicates
      end

      def run
        applications.each do |duplicate|
          config = duplicate.configuration
          config.compile true

          config.files.each do |file|
            Compiler.compile(config, file)
          end
        end
      end

      private

      def applications
        @duplicates.empty? ?
          [Lotus::Assets] : @duplicates
      end

      def basename(file)
        File.basename(
          file.to_s.sub(/\.(.*)\z/, '')
        )
      end
    end
  end
end
