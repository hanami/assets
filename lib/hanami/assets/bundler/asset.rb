require 'openssl'

module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      class Asset
        attr_reader :path, :configuration

        # @since 0.1.0
        # @api private
        WILDCARD_EXT = '.*'.freeze

        # Return a new instance
        #
        # @since x.x.x
        # @api private
        def initialize(path, configuration)
          @path = path
          @configuration = configuration
        end

        # @since x.x.x
        # @api private
        def expanded_path
          ::File.expand_path(@path)
        end

        # @since x.x.x
        # @api private
        def fingerprinted_target
          ::File.join(directory, "#{ filename }-#{ fingerprint }#{ extension }")
        end

        # @since x.x.x
        # @api private
        def expanded_fingerprinted_target
          ::File.expand_path(fingerprinted_target)
        end

        # @since x.x.x
        # @api private
        def base64_digest(algorithm)
          raw_digest(algorithm).base64digest
        end

        private

        # @since x.x.x
        # @api private
        def directory
          ::File.dirname(@path)
        end

        # @since x.x.x
        # @api private
        def filename
          ::File.basename(@path, WILDCARD_EXT)
        end

        # @since x.x.x
        # @api private
        def extension
          ::File.extname(@path)
        end

        # @since x.x.x
        # @api private
        def fingerprint
          raw_digest(:md5).hexdigest
        end

        # @since x.x.x
        # @api private
        def raw_digest(algorithm)
          OpenSSL::Digest.new(algorithm.to_s, contents)
        end

        # @since x.x.x
        # @api private
        def contents
          ::File.read(@path)
        end
      end
    end
  end
end
