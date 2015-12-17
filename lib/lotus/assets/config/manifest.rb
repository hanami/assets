module Lotus
  module Assets
    # This error is raised when the application starts but can't be load the
    # digest manifest.
    #
    # @since x.x.x
    # @api private
    class MissingDigestManifestError < Error
      def initialize(path)
        super("Can't read manifest: #{ path }")
      end
    end

    # This error is raised when an asset is referenced from the DOM, but it's
    # not present in the digest manifest
    #
    # @since x.x.x
    # @api private
    class MissingDigestAssetError < Error
      def initialize(asset, manifest_path)
        super("Can't find asset `#{ asset }' in manifest (#{ manifest_path })")
      end
    end

    # Configuration settings
    #
    # @since x.x.x
    # @api private
    module Config
      # Default value for configuration's digest manifest.
      #
      # It indicates that the digest manifest wasn't loaded yet.
      #
      # At the load time, this should be replaced by an instance of
      # <tt>Lotus::Assets::Config::Manifest</tt>.
      #
      # If for some reason that won't happen, the instance of this class is
      # still referenced by the configuration and all the method invocations
      # will raise a <tt>Lotus::Assets::MissingDigestManifestError</tt>.
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Assets::Configuration#manifest
      # @see Lotus::Assets::Configuration#manifest_path
      # @see Lotus::Assets::Configuration#digest
      class NullDigestManifest < Utils::BasicObject
        # Return a new instance
        #
        # @param configuration [Lotus::Assets::Configuration]
        #
        # @return [Lotus::Assets::Config::NullDigestManifest] a new instance
        #
        # @since x.x.x
        # @api private
        def initialize(configuration)
          @configuration = configuration
        end

        # @raise [Lotus::Assets::MissingDigestManifestError]
        #
        # @since x.x.x
        # @api private
        def method_missing(*)
          ::Kernel.raise(
            ::Lotus::Assets::MissingDigestManifestError.new(@configuration.manifest_path)
          )
        end
      end

      # Digest manifest
      #
      # @since x.x.x
      # @api private
      class DigestManifest
        # Return a new instance
        #
        # @param assets [Hash] the content of the digest manifest
        # @param manifest_path [Pathname] the path to the digest manifest
        #
        # @return [Lotus::Assets::Config::Manifest] a new instance
        #
        # @since x.x.x
        # @api private
        #
        # @see Lotus::Assets::Configuration#manifest
        # @see Lotus::Assets::Configuration#manifest_path
        def initialize(assets, manifest_path)
          @assets        = assets
          @manifest_path = manifest_path
        end

        # Resolve the given asset into a digest path
        #
        # For a given path <tt>/assets/application.js</tt> it will return
        # <tt>/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js</tt>
        #
        # @param asset [#to_s] the relateive asset path
        #
        # @return [String] the digest path
        #
        # @raise [Lotus::Assets::MissingDigestAssetError] when the asset can't be
        #   found in manifest
        def resolve(asset)
          @assets.fetch(asset.to_s) do
            raise Lotus::Assets::MissingDigestAssetError.new(asset, @manifest_path)
          end
        end
      end
    end
  end
end
