require 'lotus/assets/helpers/asset_tags'

module Lotus
  module Assets
    module Helpers
      def javascript(*sources)
        AssetTags.render(:javascript, *sources)
      end

      def stylesheet(*sources)
        AssetTags.render(:stylesheet, *sources)
      end
    end
  end
end
