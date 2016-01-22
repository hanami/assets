require 'hanami/assets/compressors/javascript'
require 'yui/compressor'

module Hanami
  module Assets
    module Compressors
      # YUI Compressor for JavaScript
      #
      # It depends on <tt>yui-compressor</tt> gem
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      class YuiJavascript < Javascript
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = YUI::JavaScriptCompressor.new(munge: true)
        end
      end
    end
  end
end
