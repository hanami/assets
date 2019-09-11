module Hanami
  module Assets
    module Less
      # Wrapper class for Less compiler
      class Engine
        LINE_NUMBER = nil

        def initialize(template, options = {})
          @renderer = source.new(template, LINE_NUMBER, options)
        end

        def render
          renderer.render
        end

        private

        attr_reader :renderer

        def source
          Tilt
        end
      end
    end
  end
end
