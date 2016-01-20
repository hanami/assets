require 'hanami/assets/compressors/javascript'
require 'closure-compiler'

module Hanami
  module Assets
    module Compressors
      # Google Closure Compiler for JavaScript
      #
      # Depends on <tt>closure-compiler</tt> gem
      #
      # @see https://developers.google.com/closure/compiler
      # @see https://rubygems.org/gems/closure-compiler
      #
      # @since 0.1.0
      # @api private
      class ClosureJavascript < Javascript
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = Closure::Compiler.new
        end
      end
    end
  end
end
