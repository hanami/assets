module Hanami
  module Assets
    module Sass
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
          begin
            require 'sassc'
            ::SassC
          rescue LoadError => err
            begin
              require 'sass'
              ::Sass
            rescue LoadError
              raise err
            end
          end
        end
      end
    end
  end
end
