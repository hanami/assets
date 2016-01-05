require 'lotus/assets/compressors/stylesheet'
require 'yui/compressor'

module Lotus
  module Assets
    module Compressors
      class YuiStylesheet < Stylesheet
        def initialize
          @compressor = YUI::CssCompressor.new
        end

        def compress(file)
          compressor.compress(read(file))
        end
      end
    end
  end
end
