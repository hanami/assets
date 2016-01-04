require 'yui/compressor'

module Lotus
  module Assets
    module Compressors
      class YuiJavascript < Javascript
        def initialize
          @compressor = YUI::JavaScriptCompressor.new(munge: true)
        end
      end
    end
  end
end
