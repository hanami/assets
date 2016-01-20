require 'hanami/assets/compressors/javascript'
require_relative './jsmin'

module Hanami
  module Assets
    module Compressors
      # Builtin compressor for stylesheet
      #
      # This is a port of jsmin
      # Copyright (c) 2002 Douglas Crockford  (www.crockford.com)
      #
      # This Ruby port was implemented by Ryan Grove (@rgrove) as work for
      # <tt>jsmin</tt> gem.
      #
      # Copyright (c) 2008-2012 Ryan Grove
      #
      # @since 0.1.0
      # @api private
      #
      # @see https://github.com/sbecker/asset_packager
      class BuiltinJavascript < Javascript
        def initialize
          @compressor = JSMin
        end

        # @since 0.1.0
        # @api private
        def compress(filename)
          compressor.minify(
            read(filename)
          )
        end
      end
    end
  end
end
