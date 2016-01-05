require 'lotus/assets/compressors/javascript'
require 'yui/compressor'

module Lotus
  module Assets
    module Compressors
      # YUI Compressor for JavaScript
      #
      # It depends on <tt>yui-compressor</tt> gem
      #
      # @since x.x.x
      # @api private
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      class YuiJavascript < Javascript
        # @since x.x.x
        # @api private
        def initialize
          @compressor = YUI::JavaScriptCompressor.new(munge: true)
        end
      end
    end
  end
end
