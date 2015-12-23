require 'lotus/assets/helpers'
require 'lotus/utils/basic_object'

module Lotus
  module Assets
    # Rendering context for assets
    #
    # @since x.x.x
    # @api private
    class RenderingContext < Utils::BasicObject
      include ::Lotus::Assets::Helpers

      def initialize(configuration)
        @configuration = configuration
      end

      private

      def _configuration
        @configuration
      end
    end
  end
end
