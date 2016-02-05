require 'hanami/assets/compiler'

module Hanami
  module Assets
    # Precompile all the assets, coming from all the applications and third
    # party gems into the public directory of the project.
    #
    # @since 0.1.0
    # @api private
    class Precompiler
      # Return a new instance
      #
      # @param configuration [Hanami::Assets::Configuration] the MAIN
      #   configuration of Hanami::Assets
      #
      # @param duplicates [Array<Hanami::Assets>] the duplicated frameworks
      #   (one for each application)
      #
      # @return [Hanami::Assets::Precompiler] a new instance
      #
      # @since 0.1.0
      # @api private
      def initialize(configuration, duplicates)
        @configuration = configuration
        @duplicates    = duplicates
      end

      # Start the process
      #
      # @since 0.1.0
      # @api private
      def run
        clear_public_directory
        precompile
      end

      private

      # @since 0.1.0
      # @api private
      def clear_public_directory
        public_directory = @configuration.public_directory
        public_directory.rmtree if public_directory.exist?
      end

      # @since 0.1.0
      # @api private
      def precompile
        applications.each do |duplicate|
          config = if duplicate.respond_to?(:configuration)
                     duplicate.configuration
                   else
                     duplicate
                   end

          config.compile true

          config.files.each do |file|
            Compiler.compile(config, file)
          end
        end
      end

      # @since 0.1.0
      # @api private
      def applications
        @duplicates.empty? ?
          [@configuration] : @duplicates
      end
    end
  end
end
