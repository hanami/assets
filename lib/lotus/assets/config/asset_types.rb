require 'lotus/utils/hash'
require 'lotus/assets/config/asset_type'

module Lotus
  module Assets
    class UnknownAssetType < ::StandardError
      def initialize(type)
        super("Unknown asset type: `#{ type }'")
      end
    end

    module Config
      class AssetTypes
        def initialize_copy(original)
          @types = original.instance_variable_get(:@types).deep_dup
        end

        def initialize(prefix)
          @prefix = prefix
          @types  = Utils::Hash.new({
            javascript: Config::AssetType.new(@prefix) {
              tag %(<script src="%s" type="text/javascript"></script>)
              ext %(.js)
            },
            stylesheet: Config::AssetType.new(@prefix) {
              tag %(<link href="%s" type="text/css" rel="stylesheet">)
              ext %(.css)
            }
          })
        end

        def each(&blk)
          @types.each(&blk)
        end

        def define(type, &blk)
          @types[type.to_sym] ||= Config::AssetType.new(@prefix)
          @types[type.to_sym].define(&blk)
        end

        def asset(type)
          @types.fetch(type) { raise UnknownAssetType.new(type) }
        end

        def types
          @types.keys
        end
      end
    end

  end
end
