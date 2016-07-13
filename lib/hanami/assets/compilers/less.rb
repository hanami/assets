module Hanami
  module Assets
    module Compilers
      # LESS compiler
      #
      # @since x.x.x
      # @api private
      class Less < Compiler
        # @since x.x.x
        # @api private
        EXTENSIONS = /\.(less)\z/

        # @since x.x.x
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        private

        # @since x.x.x
        # @api private
        def renderer
          Tilt.new(source, nil, paths: load_paths)
        end
      end
    end
  end
end
