require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      # No-op, it returns the asset contents without to compress them.
      #
      # @since x.x.x
      # @api private
      class NullCompressor < Abstract
        # @since x.x.x
        # @api private
        def compress(filename)
          read(filename)
        end
      end
    end
  end
end
