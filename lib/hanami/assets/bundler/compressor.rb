module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      class Compressor
        # @since 0.1.0
        # @api private
        JAVASCRIPT_EXT      = '.js'.freeze

        # @since 0.1.0
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

        # @since 0.1.0
        # @api private
        def compress
          case File.extname(@path)
          when JAVASCRIPT_EXT then _compress(compressor(:js))
          when STYLESHEET_EXT then _compress(compressor(:css))
          end
        end

        private

        # @since 0.1.0
        # @api private
        def compressor(type)
          @configuration.__send__(:"#{ type }_compressor")
        end

        # @since 0.1.0
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
