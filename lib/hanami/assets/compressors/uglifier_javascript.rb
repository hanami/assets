require 'hanami/assets/compressors/javascript'
require 'uglifier'

module Hanami
  module Assets
    module Compressors
      # Uglifier compressor for JavaScript
      #
      # It depends on <tt>uglifier</tt> gem
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://lisperator.net/uglifyjs
      # @see https://rubygems.org/gems/uglifier
      class UglifierJavascript < Javascript
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = Uglifier.new
        end
      end
    end
  end
end
