# frozen_string_literal: true

module Hanami
  class Assets
    # Base URL
    #
    # @since 2.1.0
    # @api private
    class BaseUrl
      # @since 2.1.0
      # @api private
      SEPARATOR = "/"
      private_constant :SEPARATOR

      # @since 2.1.0
      # @api private
      attr_reader :url
      private :url

      # Initialize a base URL
      #
      # @param url [String] the URL
      # @param prefix [String,NilClass] the prefix
      #
      # @since 2.1.0
      # @api private
      def initialize(url, prefix = nil)
        @url = URI(url + prefix.to_s).to_s
        freeze
      end

      # Join the base URL with the given paths
      #
      # @param other [String] the paths
      # @return [String] the joined URL
      #
      # @since 2.1.0
      # @api private
      def join(other)
        (url + other).to_s
      end

      # @since 2.1.0
      # @api private
      def to_s
        @url
      end

      # Check if the source is a cross origin
      #
      # @param source [String] the source
      # @return [Boolean] true if the source is a cross origin
      #
      # @since 2.1.0
      # @api private
      def crossorigin?(source)
        # TODO: review if this is the right way to check for cross origin
        return true if @url.empty?

        !source.start_with?(@url)
      end
    end
  end
end
