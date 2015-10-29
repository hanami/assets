require 'digest'
require 'fileutils'
require 'json'
require 'yui/compressor'

module Lotus
  module Assets
    class Bundler
      DEFAULT_PERMISSIONS = 0644

      def initialize(configuration)
        @configuration = configuration
        @manifest      = Hash.new
      end

      def run
        assets.each do |asset|
          next if ::File.directory?(asset)

          compress(asset)
          checksum(asset)
        end

        generate_manifest
      end

      private

      def assets
        Dir.glob("#{ destination }/**/*")
      end

      def compress(asset)
        case File.extname(asset)
        when ".js"  then _compress(YUI::JavaScriptCompressor.new(munge: true), asset)
        when ".css" then _compress(YUI::CssCompressor.new, asset)
        end
      end

      def checksum(asset)
        digest        = Digest::MD5.file(asset)
        filename, ext = ::File.basename(asset, '.*'), ::File.extname(asset)
        directory     = ::File.dirname(asset)
        target        = [directory, "#{ filename }-#{ digest }#{ ext }"].join(::File::SEPARATOR)

        FileUtils.cp(asset, target)
        _set_permissions(target)

        store_manifest(asset, target)
      end

      def generate_manifest
        _write(@configuration.manifest_path, JSON.dump(@manifest))
      end

      def store_manifest(asset, target)
        @manifest[_convert_to_url(::File.expand_path(asset))] = _convert_to_url(::File.expand_path(target))
      end

      def _compress(compressor, asset)
        _write(asset, compressor.compress(::File.read(asset)))
      end

      def _convert_to_url(path)
        path.sub(@configuration.public_path, '').
          gsub(File::SEPARATOR, '/')
      end

      def _write(path, content)
        ::File.write(path, content)
        _set_permissions(path)
      end

      def _set_permissions(path)
        ::File.chmod(DEFAULT_PERMISSIONS, path)
      end

      def destination
        @configuration.destination
      end
    end
  end
end
