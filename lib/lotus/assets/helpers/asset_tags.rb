require 'lotus/assets/helpers/asset_tag'

module Lotus
  module Assets
    module Helpers
      class AssetTags
        LINE_SEPARATOR = "\n".freeze

        # FIXME test the behavior when sources is nil
        def self.render(type, *sources)
          sources.map do |source|
            AssetTag.render(configuration, type, source)
          end.join(LINE_SEPARATOR)
        end

        private
        def self.configuration
          Lotus::Assets.configuration
        end
      end
    end
  end
end
