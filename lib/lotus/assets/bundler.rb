require 'digest'
require 'fileutils'
require 'yui/compressor'

module Lotus
  module Assets
    class Bundler
      DEFAULT_PERMISSIONS = 0644

      def initialize(configuration)
        @configuration = configuration
      end

      def run
        assets.each do |asset|
          next if ::File.directory?(asset)

          compress(asset)
          checksum(asset)
        end
      end

      private

      def assets
        Dir.glob("#{ @configuration.destination }/**/*")
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
        destination   = [directory, "#{ filename }-#{ digest }#{ ext }"].join(::File::SEPARATOR)

        FileUtils.cp(asset, destination)
        ::File.chmod(DEFAULT_PERMISSIONS, destination)
      end

      def _compress(compressor, asset)
        ::File.write(asset, compressor.compress(::File.read(asset)))
      end
    end
  end
end
