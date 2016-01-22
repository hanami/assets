require 'hanami/assets/compressors/stylesheet'
require 'yui/compressor'

module Hanami
  module Assets
    module Compressors
      # YUI Compressor for stylesheet
      #
      # It depends on <tt>yui-compressor</tt> gem
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      class YuiStylesheet < Stylesheet
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = YUI::CssCompressor.new
        end
      end
    end
  end
end
