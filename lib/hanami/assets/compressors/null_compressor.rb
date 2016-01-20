require 'hanami/assets/compressors/abstract'

module Hanami
  module Assets
    module Compressors
      # No-op, it returns the asset contents without to compress them.
      #
      # @since 0.1.0
      # @api private
      class NullCompressor < Abstract
        # @since 0.1.0
        # @api private
        def compress(filename)
          read(filename)
        end
      end
    end
  end
end
