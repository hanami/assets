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
      attr_reader :config
      private :config

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

      # @api private
      # @since 2.1.0
      attr_reader :base_url
      private :base_url

      # Returns the asset's subresource integrity value, or nil if none is available.
      #
      # @return [String, nil]
      #
      # @api public
      # @since 2.1.0
      attr_reader :sri

      # @api private
      # @since 2.1.0
      def initialize(path:, base_url:, sri: nil)
        @path = path
        @base_url = base_url
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
        base_url.join(path)
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
