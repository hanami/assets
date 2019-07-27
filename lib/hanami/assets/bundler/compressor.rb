module Hanami
  module Assets
    class Bundler
      # Compresses a JS or CSS file
      #
      # @since 0.3.0
      # @api private
      class Compressor
        # @since 0.3.0
        # @api private
        JAVASCRIPT_EXT      = '.js'.freeze

        # @since 0.3.0
        # @api private
        STYLESHEET_EXT      = '.css'.freeze

        # Return a new instance
        #
        # @since 0.3.0
        # @api private
        def initialize(path, configuration)
          @path = path
          @configuration = configuration
        end

        # @return [String, nil] the compressed contents of the file OR nil if it's not compressable
        #
        # @since 0.3.0
        # @api private
        def compress
          case File.extname(@path)
          when JAVASCRIPT_EXT then _compress(compressor(:js))
          when STYLESHEET_EXT then _compress(compressor(:css))
          end
        end

        private

        # @since 0.3.0
        # @api private
        def compressor(type)
          @configuration.__send__(:"#{ type }_compressor")
        end

        # @since 0.3.0
        # @api private
        def _compress(compressor)
          compressor.compress(@path)
        rescue => exception # rubocop:disable Style/RescueStandardError
          warn(
            [
              "Skipping compression of: `#{@path}'",
              "Reason: #{exception}\n",
              "\t#{exception.backtrace.join("\n\t")}\n\n"
            ].join("\n")
          )
        end
      end
    end
  end
end
