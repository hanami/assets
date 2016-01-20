require 'digest'
require 'fileutils'
require 'json'

module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      # @since 0.1.0
      # @api private
      DEFAULT_PERMISSIONS = 0644

      # @since 0.1.0
      # @api private
      JAVASCRIPT_EXT      = '.js'.freeze

      # @since 0.1.0
      # @api private
      STYLESHEET_EXT      = '.css'.freeze

      # @since 0.1.0
      # @api private
      WILDCARD_EXT        = '.*'.freeze

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
        @manifest       = Hash.new
        @configuration  = configuration
        @configurations = if duplicates.empty?
                            [@configuration]
                          else
                            duplicates.map(&:configuration)
                          end
      end

      # Start the process.
      #
      # For each asset contained in the sources and third party gems, it will:
      #
      #   * Compress
      #   * Create a checksum version
      #
      # At the end it will generate a digest manifest
      #
      # @see Hanami::Assets::Configuration#digest
      # @see Hanami::Assets::Configuration#manifest
      # @see Hanami::Assets::Configuration#manifest_path
      def run
        assets.each do |asset|
          next if ::File.directory?(asset)

          compress(asset)
          checksum(asset)
        end

        generate_manifest
      end

      private

      # @since 0.1.0
      # @api private
      def assets
        Dir.glob("#{ public_directory }#{ ::File::SEPARATOR }**#{ ::File::SEPARATOR }*")
      end

      # @since 0.1.0
      # @api private
      def compress(asset)
        case File.extname(asset)
        when JAVASCRIPT_EXT then _compress(compressor(:js, asset),  asset)
        when STYLESHEET_EXT then _compress(compressor(:css, asset), asset)
        end
      end

      # @since 0.1.0
      # @api private
      def checksum(asset)
        digest        = Digest::MD5.file(asset)
        filename, ext = ::File.basename(asset, WILDCARD_EXT), ::File.extname(asset)
        directory     = ::File.dirname(asset)
        target        = [directory, "#{ filename }-#{ digest }#{ ext }"].join(::File::SEPARATOR)

        FileUtils.cp(asset, target)
        _set_permissions(target)

        store_manifest(asset, target)
      end

      # @since 0.1.0
      # @api private
      def generate_manifest
        _write(@configuration.manifest_path, JSON.dump(@manifest))
      end

      # @since 0.1.0
      # @api private
      def store_manifest(asset, target)
        @manifest[_convert_to_url(::File.expand_path(asset))] = _convert_to_url(::File.expand_path(target))
      end

      # @since 0.1.0
      # @api private
      def compressor(type, asset)
        _configuration_for(asset).__send__(:"#{ type }_compressor")
      end

      # @since 0.1.0
      # @api private
      def _compress(compressor, asset)
        _write(asset, compressor.compress(asset))
      rescue => e
        warn "Skipping compression of: `#{ asset }'\nReason: #{ e }\n\t#{ e.backtrace.join("\n\t") }\n\n"
      end

      # @since 0.1.0
      # @api private
      def _convert_to_url(path)
        path.sub(public_directory.to_s, URL_REPLACEMENT).
          gsub(File::SEPARATOR, URL_SEPARATOR)
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

      def _configuration_for(asset)
        url = _convert_to_url(asset)

        @configurations.find {|config| url.start_with?(config.prefix) } ||
          @configuration
      end

      # @since 0.1.0
      # @api private
      def public_directory
        @configuration.public_directory
      end
    end
  end
end
