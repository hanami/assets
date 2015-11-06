require 'lotus/utils/hash'
require 'lotus/assets/config/asset_type'

module Lotus
  module Assets
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
          @types.fetch(type) { extension_lookup(type) }
        end

        def types
          @types.keys
        end

        private

        def extension_lookup(filename)
          @types.values.each do |asset_type|
            return asset_type if filename.match(/#{ asset_type.ext }/)
          end

          Config::AssetType.new(@prefix) { ext ::File.extname(filename.to_s) }
        end
      end
    end

  end
end
