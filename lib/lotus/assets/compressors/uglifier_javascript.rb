require 'lotus/assets/compressors/javascript'
require 'uglifier'

module Lotus
  module Assets
    module Compressors
      class UglifierJavascript < Javascript
        def initialize
          @compressor = Uglifier.new
        end

        def compress(file)
          compressor.compile(
            read(file)
          )
        end
      end
    end
  end
end
