# frozen_string_literal: true

module Hanami
  class Assets
    # Represents a single front end asset.
    #
    # @api public
    # @since 2.1.0
    class Asset
      # @api private
      # @since 2.1.0
      attr_reader :configuration
      private :configuration

      # Returns the asset's absolute URL path.
      #
      # @example Asset from local dev server
      #   asset.path # => "/assets/app.js"
      #
      # @example Deployed asset with fingerprinted name
      #   asset.path # => "/assets/app-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @return [String]
      #
      # @api public
      # @since 2.1.0
      attr_reader :path

      # Returns the asset's subresource integrity value, or nil if none is available.
      #
      # @return [String, nil]
      #
      # @api public
      # @since 2.1.0
      attr_reader :sri

      # @api private
      # @since 2.1.0
      def initialize(configuration:, path:, sri: nil)
        @configuration = configuration
        @path = path
        @sri = sri
      end

      # @api public
      # @since 2.1.0
      alias_method :subresource_integrity_value, :sri

      # Returns the asset's full URL.
      #
      # @example Asset from local dev server
      #   asset.path # => "https://example.com/assets/app.js"
      #
      # @example Deployed asset with fingerprinted name
      #   asset.path # => "https://example.com/assets/app-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @return [String]
      #
      # @api public
      # @since 2.1.0
      def url
        configuration.base_url.join(path)
      end

      # Returns the asset's full URL
      #
      # @return [String]
      #
      # @see #url
      #
      # @api public
      # @since 2.1.0
      def to_s
        url
      end
    end
  end
end
