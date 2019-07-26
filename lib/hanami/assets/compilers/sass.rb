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
          Tilt.new(source, nil, load_paths: load_paths)
        end

        # @since 0.3.0
        # @api private
        def dependencies
          engine.render
          engine.dependencies.map { |d| d.options[:filename] }
        end

        # @since 0.3.0
        # @api private
        def engine
          @engine ||= ::SassC::Engine.new(
            to_be_compiled,
            load_paths: load_paths,
            syntax: (:sass if ::File.extname(source.to_s) == ".sass")
          )
        end

        # @since x.x.x
        # @api private
        def to_be_compiled
          ::File.read(source.to_s)
        end
      end
    end
  end
end
