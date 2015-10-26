module Lotus
  module Assets
    class Precompiler
      def self.run
        new.run
      end

      def initialize
        @configuration = Lotus::Assets.configuration
      end

      def run
        applications.each do |duplicate|
          config = duplicate.configuration
          config.compile true

          config.files.each do |file|
            file = Pathname.new(file)
            next if file.directory?

            Compiler.compile(config, file.to_s, basename(file))
          end
        end
      end

      private

      def applications
        Lotus::Assets.duplicates.empty? ?
          [Lotus::Assets] : Lotus::Assets.duplicates
      end

      def basename(file)
        File.basename(
          file.to_s.sub(/\.(.*)\z/, '')
        )
      end
    end
  end
end
