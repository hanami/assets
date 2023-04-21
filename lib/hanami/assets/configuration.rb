# frozen_string_literal: true

require_relative "./base_url"
require_relative "./manifest"

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      # ESBUILD_SCRIPT_PATH = File.expand_path(
      #   File.join(__dir__, "..", "assets.mjs"),
      #   File.join(__dir__, "..")
      # ).freeze

      ESBUILD_SCRIPT_PATH = File.join(Dir.pwd, "node_modules", "hanami-esbuild", "dist", "hanami-esbuild.js").freeze
      private_constant :ESBUILD_SCRIPT_PATH

      ENTRY_POINTS_PATTERN = "index.{js,jsx,ts,tsx}"
      private_constant :ENTRY_POINTS_PATTERN

      BASE_URL = ""
      private_constant :BASE_URL

      PATH_PREFIX = "/assets"
      private_constant :PATH_PREFIX

      attr_accessor :destination, :subresource_integrity
      attr_reader :sources, :base_url, :esbuild_script, :manifest

      def initialize(esbuild_script: ESBUILD_SCRIPT_PATH, entry_points: ENTRY_POINTS_PATTERN,
        base_url: BASE_URL, prefix: PATH_PREFIX, manifest: nil, &blk)

        @esbuild_script = esbuild_script
        @entry_points = entry_points
        @base_url = BaseUrl.new(base_url)
        @manifest_path = manifest
        @manifest = Manifest::Null.new(prefix)
        @subresource_integrity = []
        instance_eval(&blk)
      end

      def finalize!
        @manifest = Manifest.new(@manifest_path)
        freeze
      end

      def sources=(*values)
        values = Array(values).flatten
        @sources = values
      end

      def entry_points
        sources.map do |source|
          Dir.glob(File.join(source, "**", @entry_points))
        end.flatten
      end

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

      def subresource_integrity_value(source)
        manifest.call(source).fetch("sri")
      end
    end
  end
end
