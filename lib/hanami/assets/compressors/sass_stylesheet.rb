require 'hanami/assets/compressors/stylesheet'
require 'hanami/assets/sass/engine'

module Hanami
  module Assets
    module Compressors
      # Sass compressor for stylesheet
      #
      # It depends on <tt>sassc</tt> gem.
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://sass-lang.com
      # @see https://rubygems.org/gems/sass
      class SassStylesheet < Stylesheet
        # @since 0.1.0
        # @api private
        def initialize
          @compressor = Hanami::Assets::Sass::Engine
        end

        # @since 0.1.0
        # @api private
        def compress(filename)
          compressor.new(
            read(filename),
            filename: filename,
            syntax: :scss,
            style: :compressed
          ).render
        end
      end
    end
  end
end
