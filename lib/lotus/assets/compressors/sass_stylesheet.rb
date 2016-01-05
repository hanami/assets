require 'lotus/assets/compressors/stylesheet'
require 'sass'

module Lotus
  module Assets
    module Compressors
      # Sass compressor for stylesheet
      #
      # It depends on <tt>sass</tt> gem.
      #
      # @since x.x.x
      # @api private
      #
      # @see http://sass-lang.com
      # @see https://rubygems.org/gems/sass
      class SassStylesheet < Stylesheet
        # @since x.x.x
        # @api private
        #
        # FIXME This is the same logic that we have for Lotus::Assets::Compiler
        SASS_CACHE_LOCATION = Pathname(Lotus.respond_to?(:root) ?
                                       Lotus.root : Dir.pwd).join('tmp', 'sass-cache')
        # @since x.x.x
        # @api private
        def initialize
          @compressor = Sass::Engine
        end

        # @since x.x.x
        # @api private
        def compress(filename)
          compressor.new(read(filename), filename: filename, syntax: :scss,
            style: :compressed, cache_location: SASS_CACHE_LOCATION).render
        end
      end
    end
  end
end
