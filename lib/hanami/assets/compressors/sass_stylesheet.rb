require 'hanami/assets/compressors/stylesheet'

module Hanami
  module Assets
    module Compressors
      # Sass compressor for stylesheet
      #
      # It depends on <tt>sass-embedded</tt> gem.
      #
      # @since 0.1.0
      # @api private
      #
      # @see http://sass-lang.com
      # @see https://rubygems.org/gems/sass-embedded
      class SassStylesheet < Stylesheet
        # @since 0.1.0
        # @api private
        def initialize
          require 'sass-embedded'
        end

        # @since 0.1.0
        # @api private
        def compress(filename)
          ::Sass.compile(filename, style: :compressed).css
        end
      end
    end
  end
end
