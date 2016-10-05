require 'fileutils'
require 'json'

require 'hanami/assets/bundler/compressor'
require 'hanami/assets/bundler/asset'
require 'hanami/assets/bundler/manifest_entry'

module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      # @since 0.1.0
      # @api private
      DEFAULT_PERMISSIONS = 0o644

      # @since 0.1.0
      # @api private
      URL_SEPARATOR       = '/'.freeze

      # @since 0.1.0
      # @api private
      URL_REPLACEMENT     = ''.freeze

      # Return a new instance
      #
      # @param configuration [Hanami::Assets::Configuration] a single application configuration
      #
      # @param duplicates [Array<Hanami::Assets>] the duplicated frameworks
      #   (one for each application)
      #
      # @return [Hanami::Assets::Bundler] a new instance
      #
      # @since 0.1.0
      # @api private
      def initialize(configuration, duplicates)
        @manifest       = Hash[]
        @configuration  = configuration
        @duplicates     = duplicates
      end

      # Start the process.
      #
      # For each asset contained in the sources and third party gems, it will:
      #
      #   * Compress
      #   * Create a checksum version
      #   * Generate an integrity digest
      #
      # At the end it will generate a digest manifest
      #
      # @see Hanami::Assets::Configuration#digest
      # @see Hanami::Assets::Configuration#manifest
      # @see Hanami::Assets::Configuration#manifest_path
      def run
        assets.each do |path|
          unless File.directory?(path)
            configuration = _configuration_for(path)
            process(Asset.new(path, configuration))
          end
        end

        write_manifest_file
      end

      private

      # @since 0.3.0
      # @api private
      def process(asset)
        compress_in_place!(asset)
        copy_to_fingerprinted_location!(asset)
        @manifest.merge!(ManifestEntry.new(asset).entry)
      end

      # @since 0.3.0
      # @api private
      def copy_to_fingerprinted_location!(asset)
        FileUtils.cp(asset.path, asset.fingerprinted_target)
        _set_permissions(asset.fingerprinted_target)
      end

      # @since 0.3.0
      # @api private
      def compress_in_place!(asset)
        compressed = Compressor.new(asset.path, asset.configuration).compress
        _write(asset.path, compressed) unless compressed.nil?
      end

      # @since 0.3.0
      # @api private
      def write_manifest_file
        _write(@configuration.manifest_path, JSON.dump(@manifest))
      end

      # @since 0.1.0
      # @api private
      def assets
        Dir.glob("#{@configuration.destination_directory}#{::File::SEPARATOR}**#{::File::SEPARATOR}*")
      end

      # @since 0.1.0
      # @api private
      def _convert_to_url(path)
        path.sub(public_directory.to_s, URL_REPLACEMENT)
            .gsub(File::SEPARATOR, URL_SEPARATOR)
      end

      # @since 0.1.0
      # @api private
      def _write(path, content)
        Pathname.new(path).dirname.mkpath
        ::File.write(path, content)

        _set_permissions(path)
      end

      # @since 0.1.0
      # @api private
      def _set_permissions(path)
        ::File.chmod(DEFAULT_PERMISSIONS, path)
      end

      # @since 0.3.0
      # @api private
      def _configuration_for(asset)
        url = _convert_to_url(asset)

        configurations.find { |config| url.start_with?(config.prefix) } ||
          @configuration
      end

      # @since 0.1.0
      # @api private
      def public_directory
        @configuration.public_directory
      end

      # @since x.x.x
      # @api private
      def configurations
        if @duplicates.empty?
          [@configuration]
        else
          @duplicates.map { |dup| dup.respond_to?(:configuration) ? dup.configuration : dup }
        end
      end
    end
  end
end
