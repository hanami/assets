# frozen_string_literal: true

require_relative "./base_url"

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      ESBUILD_SCRIPT_PATH = File.expand_path(
        File.join(__dir__, "..", "assets.mjs"),
        File.join(__dir__, "..")
      ).freeze
      private_constant :ESBUILD_SCRIPT_PATH

      ENTRY_POINTS_PATTERN = "index.{js,jsx,ts,tsx}"
      private_constant :ENTRY_POINTS_PATTERN

      BASE_URL = ""
      private_constant :BASE_URL

      PATH_PREFIX = "/assets"
      private_constant :PATH_PREFIX

      attr_accessor :destination
      attr_reader :sources, :base_url, :esbuild_script

      def initialize(esbuild_script: ESBUILD_SCRIPT_PATH,
                     entry_points: ENTRY_POINTS_PATTERN,
                     base_url: BASE_URL,
                     prefix: PATH_PREFIX, &blk)
        @esbuild_script = esbuild_script
        @entry_points = entry_points
        @base_url = BaseUrl.new(base_url, prefix)
        instance_eval(&blk)
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
        base_url.join(value)
      end
    end
  end
end
