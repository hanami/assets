require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      # Base class for stylesheet compressors
      #
      # @since x.x.x
      # @api private
      class Stylesheet < Abstract
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Assets::Compressors::Abstract#for
        def self.for(engine_name)
          super
        end
      end
    end
  end
end
