require 'lotus/assets/helpers/asset_tags'
require 'lotus/utils/escape'

module Lotus
  module Assets
    module Helpers
      def javascript(*sources)
        _asset_raw(AssetTags.render(:javascript, *sources))
      end

      def stylesheet(*sources)
        _asset_raw(AssetTags.render(:stylesheet, *sources))
      end

      private

      def _asset_raw(string)
        ::Lotus::Utils::Escape::SafeString.new(string)
      end

    end
  end
end
