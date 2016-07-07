module Hanami
  module Assets
    class Bundler
      # Compresses a JS or CSS file
      #
      # @since x.x.x
      # @api private
      class Compressor
        # @since x.x.x
        # @api private
        JAVASCRIPT_EXT      = '.js'.freeze

        # @since x.x.x
        # @api private
        STYLESHEET_EXT      = '.css'.freeze

        # Return a new instance
        #
        # @since x.x.x
        # @api private
        def initialize(path, configuration)
          @path = path
          @configuration = configuration
        end

        # @return [String, nil] the compressed contents of the file OR nil if it's not compressable
        #
        # @since x.x.x
        # @api private
        def compress
          case File.extname(@path)
          when JAVASCRIPT_EXT then _compress(compressor(:js))
          when STYLESHEET_EXT then _compress(compressor(:css))
          end
        end

        private

        # @since x.x.x
        # @api private
        def compressor(type)
          @configuration.__send__(:"#{ type }_compressor")
        end

        # @since x.x.x
        # @api private
        def _compress(compressor)
          compressor.compress(@path)
        rescue => e
          warn(
            [
              "Skipping compression of: `#{ @path }'",
              "Reason: #{ e }\n",
              "\t#{ e.backtrace.join("\n\t") }\n\n"
            ].join("\n")
          )
        end
      end
    end
  end
end
