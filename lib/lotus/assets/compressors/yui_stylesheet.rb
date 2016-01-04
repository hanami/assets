require 'yui/compressor'

module Lotus
  module Assets
    module Compressors
      class YuiStylesheet < Stylesheet
        def initialize
          @compressor = YUI::JavaScriptCompressor.new
        end
      end
    end
  end
end
