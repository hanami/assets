# frozen_string_literal: true

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      ESBUILD_SCRIPT_PATH = File.expand_path(
        File.join(__dir__, "..", "assets.js"),
        File.join(__dir__, "..")
      ).freeze
      private_constant :ESBUILD_SCRIPT_PATH

      ENTRY_POINTS_PATTERN = "index.{js,jsx,ts,tsx}"
      private_constant :ENTRY_POINTS_PATTERN

      attr_accessor :destination
      attr_reader :sources, :esbuild_script

      def initialize(esbuild_script: ESBUILD_SCRIPT_PATH, entry_points: ENTRY_POINTS_PATTERN, &blk)
        @esbuild_script = esbuild_script
        @entry_points = entry_points
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
    end
  end
end
