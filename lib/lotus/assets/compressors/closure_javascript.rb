require 'lotus/assets/compressors/javascript'
require 'closure-compiler'

module Lotus
  module Assets
    module Compressors
      class ClosureJavascript < Javascript
        def initialize
          @compressor = Closure::Compiler.new
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
