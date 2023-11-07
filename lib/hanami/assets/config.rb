# frozen_string_literal: true

require "dry/configurable"
require_relative "base_url"

module Hanami
  class Assets
    # Hanami assets configuration.
    #
    # @api public
    # @since 0.1.0
    class Config
      include Dry::Configurable

      # @api public
      # @since 2.1.0
      BASE_URL = ""
      private_constant :BASE_URL

      # @!attribute [rw] package_manager_run_command
      #   @return [String]
      #
      #   @api public
      #   @since 2.1.0
      setting :package_manager_run_command, default: "npm run --silent"

      # @!attribute [rw] path_prefix
      #   @return [String]
      #
      #   @api public
      #   @since 2.1.0
      setting :path_prefix, default: "/assets"

      # @!attribute [rw] subresource_integrity
      #   @return [Array<Symbol>]
      #
      #   @example
      #     config.subresource_integrity # => [:sha256, :sha512]
      #
      #   @api public
      #   @since 2.1.0
      setting :subresource_integrity, default: []

      # @!attribute [rw] base_url
      #   @return [BaseUrl]
      #
      #   @example
      #     config.base_url = "http://some-cdn.com/assets"
      #
      #   @api public
      #   @since 2.1.0
      setting :base_url, constructor: -> url { BaseUrl.new(url.to_s) }

      # @!attribute [rw] manifest_path
      #   @return [String, nil]
      #
      #   @api public
      #   @since 2.1.0
      setting :manifest_path

      # @api public
      # @since 2.1.0
      def initialize(**values)
        super()

        config.update(values.select { |k| _settings.key?(k) })

        yield(config) if block_given?
      end

      # Returns true if the given source is linked via Cross-Origin policy (or in other words, if
      # the given source does not satisfy the Same-Origin policy).
      #
      # @param source [String]
      #
      # @return [Boolean]
      #
      # @see https://en.wikipedia.org/wiki/Same-origin_policy#Origin_determination_rules
      # @see https://en.wikipedia.org/wiki/Same-origin_policy#document.domain_property
      #
      # @api private
      # @since 1.2.0
      def crossorigin?(source)
        base_url.crossorigin?(source)
      end

      private

      def method_missing(name, ...)
        if config.respond_to?(name)
          config.public_send(name, ...)
        else
          super
        end
      end

      def respond_to_missing?(name, _incude_all = false)
        config.respond_to?(name) || super
      end
    end
  end
end
