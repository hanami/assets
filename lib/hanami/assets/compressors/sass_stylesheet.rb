require 'hanami/assets/compressors/stylesheet'
require 'sassc'

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
          @compressor = SassC::Engine
        end

        # @since 0.1.0
        # @api private
        def compress(filename)
          compressor.new(
            read(filename),
            filename: filename,
            syntax: target_syntax(filename),
            style: :compressed,
          ).render
        end

        private

        # @since 1.3.2
        # @api private
        def target_syntax(filename)
          if File.extname(filename) =~ /sass/
            :sass
          else
            :scss
          end
        end
      end
    end
  end
end
