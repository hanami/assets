require 'lotus/assets/helpers/asset_tags'
require 'lotus/utils/escape'

module Lotus
  module Assets
    module Helpers
      def javascript(*sources)
        _raw_asset(:javascript, *sources)
      end

      def stylesheet(*sources)
        _raw_asset(:stylesheet, *sources)
      end

      private

      def _raw_asset(type, *sources)
        ::Lotus::Utils::Escape::SafeString.new(
          AssetTags.render(type, *sources)
        )
      end
    end
  end
end
