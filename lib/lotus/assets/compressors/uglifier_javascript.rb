require 'lotus/assets/compressors/javascript'
require 'uglifier'

module Lotus
  module Assets
    module Compressors
      # Uglifier compressor for JavaScript
      #
      # It depends on <tt>uglifier</tt> gem
      #
      # @since x.x.x
      # @api private
      #
      # @see http://lisperator.net/uglifyjs
      # @see https://rubygems.org/gems/uglifier
      class UglifierJavascript < Javascript
        # @since x.x.x
        # @api private
        def initialize
          @compressor = Uglifier.new
        end
      end
    end
  end
end
