require 'openssl'

module Hanami
  module Assets
    # Bundle assets from a single application.
    #
    # @since 0.1.0
    # @api private
    class Bundler
      # @since 0.3.0
      # @api private
      class Asset
        # @since 0.3.0
        # @api private
        attr_reader :path

        # @since 0.3.0
        # @api private
        attr_reader :configuration

        # @since 0.3.0
        # @api private
        WILDCARD_EXT = '.*'.freeze

        # Return a new instance
        #
        # @since 0.3.0
        # @api private
        def initialize(path, configuration)
          @path = path
          @configuration = configuration
        end

        # @since 0.3.0
        # @api private
        def expanded_path
          ::File.expand_path(@path)
        end

        # @since 0.3.0
        # @api private
        def fingerprinted_target
          ::File.join(directory, "#{filename}-#{fingerprint}#{extension}")
        end

        # @since 0.3.0
        # @api private
        def expanded_fingerprinted_target
          ::File.expand_path(fingerprinted_target)
        end

        # @since 0.3.0
        # @api private
        def base64_digest(algorithm)
          raw_digest(algorithm).base64digest
        end

        private

        # @since 0.3.0
        # @api private
        def directory
          ::File.dirname(@path)
        end

        # @since 0.3.0
        # @api private
        def filename
          ::File.basename(@path, WILDCARD_EXT)
        end

        # @since 0.3.0
        # @api private
        def extension
          ::File.extname(@path)
        end

        # @since 0.3.0
        # @api private
        def fingerprint
          raw_digest(:md5).hexdigest
        end

        # @since 0.3.0
        # @api private
        def raw_digest(algorithm)
          OpenSSL::Digest.new(algorithm.to_s, contents)
        end

        # @since 0.3.0
        # @api private
        def contents
          ::File.read(@path)
        end
      end
    end
  end
end
