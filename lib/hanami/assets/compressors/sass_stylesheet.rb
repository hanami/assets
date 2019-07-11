require 'hanami/assets/compressors/stylesheet'
require 'sass'

module Hanami
  module Assets
    module Compressors
      # Sass compressor for stylesheet
      #
      # It depends on <tt>sass</tt> gem.
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://sass-lang.com
      # @see https://rubygems.org/gems/sass
      class SassStylesheet < Stylesheet
        # @since 0.1.0
        # @api private
        #
        # FIXME This is the same logic that we have for Hanami::Assets::Compiler
        SASS_CACHE_LOCATION = Pathname(Hanami.respond_to?(:root) ? # rubocop:disable Style/MultilineTernaryOperator
                                       Hanami.root : Dir.pwd).join('tmp', 'sass-cache')
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = SassC::Engine
        end

        # @since 0.1.0
        # @api private
        def compress(filename)
          compressor.new(read(filename), filename: filename, syntax: :scss,
                                         style: :compressed, cache_location: SASS_CACHE_LOCATION).render
        end
      end
    end
  end
end
