require 'lotus/assets/helpers/asset_tag'

module Lotus
  module Assets
    module Helpers
      class AssetTags
        LINE_SEPARATOR = "\n".freeze

        def self.render(configuration, type, *sources)
          sources.map do |source|
            AssetTag.render(configuration, type, source)
          end.join(LINE_SEPARATOR)
        end
      end
    end
  end
end
