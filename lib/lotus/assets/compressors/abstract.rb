module Lotus
  module Assets
    module Compressors
      class Abstract
        def self.for(value)
          case value
          when nil
            require 'lotus/assets/compressors/null_compressor'
            NullCompressor.new
          else
            value
          end
        end
        def compress(file)
          compressor.compress(file)
        end

        protected
        attr_reader :compressor
      end
    end
  end
end
