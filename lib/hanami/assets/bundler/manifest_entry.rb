module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      class ManifestEntry
        # Return a new instance
        #
        # @since x.x.x
        # @api private
        def initialize(asset)
          @asset = asset
        end

        def entry
          { name => values }
        end

        private

        def name
          _convert_to_url(@asset.expanded_path)
        end

        def values
          {
            target: _convert_to_url(@asset.expanded_fingerprinted_target),
            subresource_integrity: subresource_integrity_values
          }
        end

        # @since 0.3.0-add-options-to-javascript-helper
        # @api private
        def subresource_integrity_values
          @asset.configuration.subresource_integrity_algorithms.map do |algorithm|
            [ algorithm, @asset.base64_digest(algorithm) ].join('-')
          end
        end

        # @since 0.1.0
        # @api private
        def _convert_to_url(path)
          path.sub(@asset.configuration.public_directory.to_s, URL_REPLACEMENT).
            gsub(File::SEPARATOR, URL_SEPARATOR)
        end
      end
    end
  end
end
