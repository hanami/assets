# frozen_string_literal: true

require_relative "./base_url"
require_relative "./manifest"

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      # @since 2.1.0
      # @api private
      HANAMI_ASSETS_JAVASCRIPT_EXECUTABLE =
        File.join(Dir.pwd, "node_modules", "hanami-assets", "dist", "hanami-assets.js").freeze
      private_constant :HANAMI_ASSETS_JAVASCRIPT_EXECUTABLE

      # @since 2.1.0
      # @api private
      ENTRY_POINTS_PATTERN = "index.{js,jsx,ts,tsx}"
      private_constant :ENTRY_POINTS_PATTERN

      # @since 2.1.0
      # @api private
      BASE_URL = ""
      private_constant :BASE_URL

      # @since 2.1.0
      # @api private
      PATH_PREFIX = "/assets"
      private_constant :PATH_PREFIX

      # @since 2.1.0
      # @api private
      attr_accessor :destination

      # @since 2.1.0
      # @api private
      attr_accessor :subresource_integrity

      # @since 2.1.0
      # @api private
      attr_reader :sources

      # @since 2.1.0
      # @api private
      attr_reader :base_url

      # @since 2.1.0
      # @api private
      attr_reader :javascript_exe

      # @since 2.1.0
      # @api private
      attr_reader :manifest

      # @since 2.1.0
      # @api private
      def initialize(javascript_exe: HANAMI_ASSETS_JAVASCRIPT_EXECUTABLE,
                     entry_points: ENTRY_POINTS_PATTERN, base_url: BASE_URL,
                     prefix: PATH_PREFIX, manifest: nil, &blk)

        super()

        @javascript_exe = javascript_exe
        @entry_points = entry_points
        @base_url = BaseUrl.new(base_url)
        @manifest_path = manifest
        @manifest = Manifest::Null.new(prefix)
        @subresource_integrity = []
        instance_eval(&blk)
      end

      # @since 2.1.0
      # @api private
      def finalize!
        @manifest = Manifest.new(@manifest_path)
        freeze
      end

      # @since 2.1.0
      # @api public
      def sources=(*values)
        values = Array(values).flatten
        @sources = values
      end

      # @since 2.1.0
      # @api private
      def entry_points
        sources.map do |source|
          Dir.glob(File.join(source, "**", @entry_points))
        end.flatten
      end

      # @since 2.1.0
      # @api private
      def asset_path(value)
        path = manifest.call(value).fetch("url")
        base_url.join(path)
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

      # @since 2.1.0
      # @api private
      def subresource_integrity_value(source)
        manifest.call(source).fetch("sri")
      end
    end
  end
end
