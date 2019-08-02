module Hanami
  module Assets
    module Compilers
      # Sass/SCSS Compiler
      #
      # @since 0.3.0
      # @api private
      class Sass < Compiler
        # @since 0.3.0
        # @api private
        EXTENSIONS = /\.(sass|scss)\z/.freeze

        # @since 0.3.0
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        private

        # @since 0.3.0
        # @api private
        def renderer
          @renderer ||=
            ::SassC::Engine.new(
              source.read,
              syntax: target_syntax,
              load_paths: load_paths
            )
        end

        # @since 0.3.0
        # @api private
        def dependencies
          renderer.dependencies.map(&:filename)
        end

        # @since 1.3.2
        # @api private
        def target_syntax
          if source.extname =~ /sass\z/.freeze
            :sass
          else
            :scss
          end
        end
      end
    end
  end
end
