require 'hanami/assets/less/engine'

module Hanami
  module Assets
    module Compilers
      # LESS compiler
      #
      # @since 0.3.0
      # @api private
      class Less < Compiler
        # @since 0.3.0
        # @api private
        EXTENSIONS = /\.(less)\z/.freeze

        # @since 0.3.0
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        private

        # @since 0.3.0
        # @api private
        def renderer
          Hanami::Assets::Less::Engine.new(
            source,
            paths: load_paths
          )
        end
      end
    end
  end
end
