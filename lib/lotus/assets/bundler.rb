require 'digest'
require 'fileutils'
require 'json'
require 'yui/compressor'

module Lotus
  module Assets
    # Bundle assets from a single application.
    #
    # @since x.x.x
    # @api private
    class Bundler
      # @since x.x.x
      # @api private
      DEFAULT_PERMISSIONS = 0644

      # @since x.x.x
      # @api private
      JAVASCRIPT_EXT      = '.js'.freeze

      # @since x.x.x
      # @api private
      STYLESHEET_EXT      = '.css'.freeze

      # @since x.x.x
      # @api private
      WILDCARD_EXT        = '.*'.freeze

      # @since x.x.x
      # @api private
      URL_SEPARATOR       = '/'.freeze

      # @since x.x.x
      # @api private
      URL_REPLACEMENT     = ''.freeze

      # Return a new instance
      #
      # @param configuration [Lotus::Assets::Configuration] a single application configuration
      #
      # @return [Lotus::Assets::Bundler] a new instance
      #
      # @since x.x.x
      # @api private
      def initialize(configuration)
        @configuration = configuration
        @manifest      = Hash.new
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
      # @see Lotus::Assets::Configuration#digest
      # @see Lotus::Assets::Configuration#manifest
      # @see Lotus::Assets::Configuration#manifest_path
      def run
        assets.each do |asset|
          next if ::File.directory?(asset)

          compress(asset)
          checksum(asset)
        end

        generate_manifest
      end

      private

      # @since x.x.x
      # @api private
      def assets
        Dir.glob("#{ public_directory }#{ ::File::SEPARATOR }**#{ ::File::SEPARATOR }*")
      end

      # @since x.x.x
      # @api private
      def compress(asset)
        case File.extname(asset)
        when JAVASCRIPT_EXT then _compress(YUI::JavaScriptCompressor.new(munge: true), asset)
        when STYLESHEET_EXT then _compress(YUI::CssCompressor.new, asset)
        end
      end

      # @since x.x.x
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

      # @since x.x.x
      # @api private
      def generate_manifest
        _write(@configuration.manifest_path, JSON.dump(@manifest))
      end

      # @since x.x.x
      # @api private
      def store_manifest(asset, target)
        @manifest[_convert_to_url(::File.expand_path(asset))] = _convert_to_url(::File.expand_path(target))
      end

      # @since x.x.x
      # @api private
      def _compress(compressor, asset)
        _write(asset, compressor.compress(::File.read(asset)))
      end

      # @since x.x.x
      # @api private
      def _convert_to_url(path)
        path.sub(public_directory.to_s, URL_REPLACEMENT).
          gsub(File::SEPARATOR, URL_SEPARATOR)
      end

      # @since x.x.x
      # @api private
      def _write(path, content)
        ::File.write(path, content)
        _set_permissions(path)
      end

      # @since x.x.x
      # @api private
      def _set_permissions(path)
        ::File.chmod(DEFAULT_PERMISSIONS, path)
      end

      # @since x.x.x
      # @api private
      def public_directory
        @configuration.public_directory
      end
    end
  end
end
