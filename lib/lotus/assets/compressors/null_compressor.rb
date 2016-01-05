require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      class NullCompressor < Abstract
        def compress(file)
          read(file)
        end
      end
    end
  end
end
