module Hanami
  module Assets
    module Compilers
      # Sass/SCSS Compiler
      #
      # @since x.x.x
      # @api private
      class Sass < Compiler
        # @since x.x.x
        # @api private
        EXTENSIONS = /\.(sass|scss)\z/

        # @since 0.1.0
        # @api private
        CACHE_LOCATION = Pathname(Hanami.respond_to?(:root) ? # rubocop:disable Style/MultilineTernaryOperator
                                  Hanami.root : Dir.pwd).join('tmp', 'sass-cache')

        # @since x.x.x
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        private

        # @since x.x.x
        # @api private
        def renderer
          Tilt.new(source, nil, load_paths: load_paths, cache_location: CACHE_LOCATION)
        end

        # @since x.x.x
        # @api private
        def dependencies
          engine.dependencies.map { |d| d.options[:filename] }
        end

        # @since x.x.x
        # @api private
        def engine
          ::Sass::Engine.for_file(source.to_s, load_paths: load_paths, cache_location: CACHE_LOCATION)
        end
      end
    end
  end
end
