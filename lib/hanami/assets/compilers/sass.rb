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

        # @since 0.1.0
        # @api private
        CACHE_LOCATION = Pathname(Hanami.respond_to?(:root) ? # rubocop:disable Style/MultilineTernaryOperator
                                  Hanami.root : Dir.pwd).join('tmp', 'sass-cache')

        # @since 0.3.0
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        private

        # @since 0.3.0
        # @api private
        def renderer
          Tilt.new(source, nil, load_paths: load_paths, cache_location: CACHE_LOCATION)
        end

        # @since 0.3.0
        # @api private
        def dependencies
          engine.dependencies.map { |d| d.options[:filename] }
        end

        # @since 0.3.0
        # @api private
        def engine
          ::SassC::Engine.for_file(source.to_s, load_paths: load_paths, cache_location: CACHE_LOCATION)
        end
      end
    end
  end
end
