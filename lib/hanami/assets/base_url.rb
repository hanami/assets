# frozen_string_literal: true

module Hanami
  module Assets
    # Base URL
    #
    # @since 2.0.0
    # @api private
    class BaseUrl
      # @since 2.0.0
      # @api private
      SEPARATOR = "/"
      private_constant :SEPARATOR

      # Initialize a base URL
      #
      # @param url [String] the URL
      # @param prefix [String] the prefix
      #
      # @since 2.0.0
      # @api private
      def initialize(url, prefix)
        @url = URI(url + prefix).to_s
        freeze
      end

      # Join the base URL with the given paths
      #
      # @param other [Array<String>] the paths
      # @return [String] the joined URL
      #
      # @since 2.0.0
      # @api private
      def join(*other)
        (url + SEPARATOR + other.join(SEPARATOR)).to_s
      end

      private

      # @since 2.0.0
      # @api private
      attr_reader :url
    end
  end
end
