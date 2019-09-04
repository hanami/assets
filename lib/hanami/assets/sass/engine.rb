module Hanami
  module Assets
    module Sass
      # Wrapper class for Sass[C]::Engine meant to aid in the transition between
      # Sass (EOL) and SassC as the Sass/SCSS Compiler/stylesheet compressor
      class Engine
        def initialize(template, options = {})
          @renderer = source::Engine.new(template, options)
        end

        def render
          renderer.render
        end

        def dependencies
          renderer.dependencies.map(&:filename)
        end

        private

        attr_reader :renderer

        def source
          require 'sassc'
          ::SassC
        rescue LoadError => exception
          begin
            require 'sass'
            ::Sass
          rescue LoadError
            raise exception
          end
        end
      end
    end
  end
end
