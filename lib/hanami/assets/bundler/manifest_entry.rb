module Hanami
  module Assets
    class Bundler
      # Constructs a hash for a single asset's manifest file entry
      #
      # @since 0.3.0
      # @api private
      class ManifestEntry
        # @since 0.3.0
        # @api private
        SUBRESOURCE_INTEGRITY_SEPARATOR = '-'.freeze

        # Return a new instance
        #
        # @since 0.3.0
        # @api private
        def initialize(asset)
          @asset = asset
        end

        # A single entry for this asset, to go into manifest file
        # @since 0.3.0
        # @api private
        def entry
          { name => values }
        end

        private

        # @since 0.3.0
        # @api private
        def name
          _convert_to_url(@asset.expanded_path)
        end

        # @since 0.3.0
        # @api private
        def values
          Hash[
            target: _convert_to_url(@asset.expanded_fingerprinted_target),
            sri: subresource_integrity_values
          ]
        end

        # @since 0.3.0
        # @api private
        def subresource_integrity_values
          @asset.configuration.subresource_integrity_algorithms.map do |algorithm|
            [algorithm, @asset.base64_digest(algorithm)].join(SUBRESOURCE_INTEGRITY_SEPARATOR)
          end
        end

        # @since 0.3.0
        # @api private
        def _convert_to_url(path)
          path.sub(@asset.configuration.public_directory.to_s, URL_REPLACEMENT)
              .gsub(File::SEPARATOR, URL_SEPARATOR)
        end
      end
    end
  end
end
