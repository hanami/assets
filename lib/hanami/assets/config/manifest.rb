# frozen_string_literal: true

module Hanami
  module Assets
    # This error is raised when the application starts but can't be load the
    # manifest file.
    #
    # @since 0.1.0
    # @api private
    class MissingManifestFileError < Error
      def initialize(path)
        super("Can't read manifest: #{path}")
      end
    end

    # This error is raised when an asset is referenced from the DOM, but it's
    # not present in the manifest
    #
    # @since 0.1.0
    # @api private
    class MissingManifestAssetError < Error
      def initialize(asset, manifest_path)
        super("Can't find asset `#{asset}' in manifest (#{manifest_path})")
      end
    end

    # Configuration settings
    #
    # @since 0.1.0
    # @api private
    module Config
      # Default value for configuration's manifest.
      #
      # It indicates that the manifest wasn't loaded yet.
      #
      # At the load time, this should be replaced by an instance of
      # <tt>Hanami::Assets::Config::Manifest</tt>.
      #
      # If for some reason that won't happen, the instance of this class is
      # still referenced by the configuration and all the method invocations
      # will raise a <tt>Hanami::Assets::MissingManifestFileError</tt>.
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Configuration#manifest
      # @see Hanami::Assets::Configuration#manifest_path
      # @see Hanami::Assets::Configuration#fingerprint
      class NullManifest < CygUtils::BasicObject
        # Return a new instance
        #
        # @param configuration [Hanami::Assets::Configuration]
        #
        # @return [Hanami::Assets::Config::NullManifest] a new instance
        #
        # @since 0.1.0
        # @api private
        def initialize(configuration)
          @configuration = configuration
        end

        # @raise [Hanami::Assets::MissingManifestFileError]
        #
        # @since 0.1.0
        # @api private
        def method_missing(*) # rubocop:disable Style/MethodMissingSuper
          ::Kernel.raise(
            ::Hanami::Assets::MissingManifestFileError.new(@configuration.manifest_path)
          )
        end

        # @return [FalseClass] returns false
        #
        # @since 1.1.0
        # @api private
        def respond_to_missing?(*)
          false
        end
      end

      # Manifest file
      #
      # @since 0.1.0
      # @api private
      class Manifest
        # @since 0.4.0
        # @api private
        TARGET                = "target"

        # @since 0.3.0
        # @api private
        SUBRESOURCE_INTEGRITY = "sri"

        # Return a new instance
        #
        # @param assets [Hash] the content of the manifest
        # @param manifest_path [Pathname] the path to the manifest
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

        # Resolve the given asset into a fingerprinted path
        #
        # For a given path <tt>/assets/application.js</tt> it will return
        # <tt>/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js</tt>
        #
        # @param asset [#to_s] the relative asset path
        #
        # @return [String] the fingerprinted path
        #
        # @raise [Hanami::Assets::MissingManifestAssetError] when the asset can't be
        #   found in manifest
        def resolve(asset)
          @assets.fetch(asset.to_s) do
            raise Hanami::Assets::MissingManifestAssetError.new(asset, @manifest_path)
          end
        end

        # @since 0.3.0
        # @api private
        def target(path)
          resolve(path).fetch(TARGET)
        end

        # @since 0.3.0
        # @api private
        def subresource_integrity_values(path)
          resolve(path).fetch(SUBRESOURCE_INTEGRITY)
        end
      end
    end
  end
end
