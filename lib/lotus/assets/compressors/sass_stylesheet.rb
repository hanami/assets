require 'lotus/assets/compressors/stylesheet'
require 'sass'

module Lotus
  module Assets
    module Compressors
      class SassStylesheet < Stylesheet
        # @since x.x.x
        # @api private
        #
        # FIXME This is the same logic that we have for Lotus::Assets::Compiler
        SASS_CACHE_LOCATION = Pathname(Lotus.respond_to?(:root) ?
                                       Lotus.root : Dir.pwd).join('tmp', 'sass-cache')
        def initialize
          @compressor = Sass::Engine
        end

        def compress(file)
          compressor.new(read(file), filename: file, syntax: :scss,
            style: :compressed, cache_location: SASS_CACHE_LOCATION).render
        end
      end
    end
  end
end
