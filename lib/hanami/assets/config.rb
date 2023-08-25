# frozen_string_literal: true

require "dry/configurable"
require_relative "base_url"

module Hanami
  class Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Config
      include Dry::Configurable

      # @since 2.1.0
      # @api private
      BASE_URL = ""
      private_constant :BASE_URL

      # @since 2.1.0
      # @api private
      setting :exe_path, default: File.join("node_modules", "hanami-assets", "dist", "hanami-assets.js").freeze

      # @since 2.1.0
      # @api private
      setting :path_prefix, default: "/assets"

      # @since 2.1.0
      # @api private
      setting :destination

      # @since 2.1.0
      # @api private
      setting :subresource_integrity, default: []

      # @since 2.1.0
      # @api private
      setting :sources, default: [], constructor: -> v { Array(v).flatten }

      # @since 2.1.0
      # @api private
      setting :base_url, constructor: -> url { BaseUrl.new(url.to_s) }

      # @since 2.1.0
      # @api private
      setting :entry_points_pattern, default: "index.{js,jsx,ts,tsx}"

      # @since 2.1.0
      # @api private
      setting :manifest_path

      # @since 2.1.0
      # @api private
      def initialize(**values)
        super()

        config.update(values.select { |k| _settings.key?(k) })

        # Capture pwd at initialize-time to make sure it's the app's pwd (see `#full_exe_path`)
        @pwd = Dir.pwd

        yield(config) if block_given?
      end

      def full_exe_path
        File.join(@pwd, config.exe_path)
      end

      # @since 2.1.0
      # @api private
      def entry_points
        sources.map do |source|
          Dir.glob(File.join(source, "**", config.entry_points_pattern))
        end.flatten
      end

      # Check if the given source is linked via Cross-Origin policy.
      # In other words, the given source, doesn't satisfy the Same-Origin policy.
      #
      # @see https://en.wikipedia.org/wiki/Same-origin_policy#Origin_determination_rules
      # @see https://en.wikipedia.org/wiki/Same-origin_policy#document.domain_property
      #
      # @since 1.2.0
      # @api private
      def crossorigin?(source)
        base_url.crossorigin?(source)
      end

      private

      # @api private
      def method_missing(name, ...)
        if config.respond_to?(name)
          config.public_send(name, ...)
        else
          super
        end
      end

      # @api private
      def respond_to_missing?(name, _incude_all = false)
        config.respond_to?(name) || super
      end
    end
  end
end
