module Lotus
  module Assets
    module Compressors
      class NullCompressor
        def compress(file)
          file
        end
      end
    end
  end
end
