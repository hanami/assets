require 'fileutils'
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
        clear_assets_directory
        precompile
      end

      private

      # @since 0.3.0
      # @api private
      def clear_assets_directory
        delete @configuration.manifest_path
        delete @configuration.destination_directory
      end

      # @since 0.3.0
      # @api private
      def clear_manifest(manifest)
        JSON.parse(manifest).each_value do |asset_hash|
          asset_file_name = @configuration.public_directory.join(asset_hash['target'])
          asset_file_name.unlink if asset_file_name.exist?
        end
      rescue JSON::ParserError
        warn 'Non JSON manifest found and unlinked.'
      ensure
        manifest.unlink
      end

      # @since 0.1.0
      # @api private
      def precompile # rubocop:disable Metrics/MethodLength
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
        if @duplicates.empty?
          [@configuration]
        else
          @duplicates
        end
      end

      # @since 0.3.0
      # @api private
      def delete(path)
        FileUtils.rm_rf(path) if path.exist?
      end
    end
  end
end
