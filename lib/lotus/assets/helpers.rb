require 'lotus/assets/helpers/asset_tags'
require 'lotus/utils/escape'

module Lotus
  module Assets
    module Helpers
      def self.included(base)
        conf = ::Lotus::Assets::Configuration.for(base)
        base.class_eval do
          include Utils::ClassAttribute

          class_attribute :assets_configuration
          self.assets_configuration = conf
        end
      end

      def javascript(*sources)
        _raw_asset(:javascript, *sources)
      end

      def stylesheet(*sources)
        _raw_asset(:stylesheet, *sources)
      end

      private

      def _raw_asset(type, *sources)
        ::Lotus::Utils::Escape::SafeString.new(
          AssetTags.render(self.class.assets_configuration, type, *sources)
        )
      end
    end
  end
end
