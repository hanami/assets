require 'lotus/assets/compressors/stylesheet'
require 'yui/compressor'

module Lotus
  module Assets
    module Compressors
      # YUI Compressor for stylesheet
      #
      # It depends on <tt>yui-compressor</tt> gem
      #
      # @since x.x.x
      # @api private
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      class YuiStylesheet < Stylesheet
        # @since x.x.x
        # @api private
        def initialize
          @compressor = YUI::CssCompressor.new
        end
      end
    end
  end
end
