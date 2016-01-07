require 'lotus/assets/compressors/javascript'
require 'closure-compiler'

module Lotus
  module Assets
    module Compressors
      # Google Closure Compiler for JavaScript
      #
      # Depends on <tt>closure-compiler</tt> gem
      #
      # @see https://developers.google.com/closure/compiler
      # @see https://rubygems.org/gems/closure-compiler
      #
      # @since x.x.x
      # @api private
      class ClosureJavascript < Javascript
        # @since x.x.x
        # @api private
        def initialize
          @compressor = Closure::Compiler.new
        end
      end
    end
  end
end
