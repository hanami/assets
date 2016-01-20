module Hanami
  module Assets
    # This error is raised when the application starts but can't be load the
    # digest manifest.
    #
    # @since 0.1.0
    # @api private
    class MissingDigestManifestError < Error
      def initialize(path)
        super("Can't read manifest: #{ path }")
      end
    end

    # This error is raised when an asset is referenced from the DOM, but it's
    # not present in the digest manifest
    #
    # @since 0.1.0
    # @api private
    class MissingDigestAssetError < Error
      def initialize(asset, manifest_path)
        super("Can't find asset `#{ asset }' in manifest (#{ manifest_path })")
      end
    end

    # Configuration settings
    #
    # @since 0.1.0
    # @api private
    module Config
      # Default value for configuration's digest manifest.
      #
      # It indicates that the digest manifest wasn't loaded yet.
      #
      # At the load time, this should be replaced by an instance of
      # <tt>Hanami::Assets::Config::Manifest</tt>.
      #
      # If for some reason that won't happen, the instance of this class is
      # still referenced by the configuration and all the method invocations
      # will raise a <tt>Hanami::Assets::MissingDigestManifestError</tt>.
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Configuration#manifest
      # @see Hanami::Assets::Configuration#manifest_path
      # @see Hanami::Assets::Configuration#digest
      class NullDigestManifest < Utils::BasicObject
        # Return a new instance
        #
        # @param configuration [Hanami::Assets::Configuration]
        #
        # @return [Hanami::Assets::Config::NullDigestManifest] a new instance
        #
        # @since 0.1.0
        # @api private
        def initialize(configuration)
          @configuration = configuration
        end

        # @raise [Hanami::Assets::MissingDigestManifestError]
        #
        # @since 0.1.0
        # @api private
        def method_missing(*)
          ::Kernel.raise(
            ::Hanami::Assets::MissingDigestManifestError.new(@configuration.manifest_path)
          )
        end
      end

      # Digest manifest
      #
      # @since 0.1.0
      # @api private
      class DigestManifest
        # Return a new instance
        #
        # @param assets [Hash] the content of the digest manifest
        # @param manifest_path [Pathname] the path to the digest manifest
        #
        # @return [Hanami::Assets::Config::Manifest] a new instance
        #
        # @since 0.1.0
        # @api private
        #
        # @see Hanami::Assets::Configuration#manifest
        # @see Hanami::Assets::Configuration#manifest_path
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
        # @raise [Hanami::Assets::MissingDigestAssetError] when the asset can't be
        #   found in manifest
        def resolve(asset)
          @assets.fetch(asset.to_s) do
            raise Hanami::Assets::MissingDigestAssetError.new(asset, @manifest_path)
          end
        end
      end
    end
  end
end
