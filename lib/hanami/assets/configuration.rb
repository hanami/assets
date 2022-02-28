# frozen_string_literal: true

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      ESBUILD_PATH = File.join(".", "node_modules", ".bin", "esbuild").freeze
      private_constant :ESBUILD_PATH

      ENTRY_POINTS_PATTERN = "index.{js,jsx,ts,tsx}"
      private_constant :ENTRY_POINTS_PATTERN

      attr_accessor :destination
      attr_reader :sources, :esbuild

      def initialize(esbuild: ESBUILD_PATH, entry_points: ENTRY_POINTS_PATTERN, &blk)
        @esbuild = esbuild
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
