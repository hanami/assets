module Lotus
  module Assets
    class MissingManifestError < Error
      def initialize(path)
        super("Can't read manifest: #{ path }")
      end
    end

    class MissingAssetError < Error
      def initialize(asset, manifest_path)
        super("Can't find asset `#{ asset }' in manifest (#{ manifest_path })")
      end
    end

    module Config
      class NullDigestManifest < Utils::BasicObject
        def initialize(configuration)
          @configuration = configuration
        end

        def method_missing(*)
          ::Kernel.raise(
            ::Lotus::Assets::MissingManifestError.new(@configuration.manifest_path)
          )
        end
      end

      class Manifest
        def initialize(assets, manifest_path)
          @assets        = assets
          @manifest_path = manifest_path
        end

        def resolve(asset)
          @assets.fetch(asset.to_s) do
            raise Lotus::Assets::MissingAssetError.new(asset, @manifest_path)
          end
        end
      end
    end
  end
end
