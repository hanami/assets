# frozen_string_literal: true

require "open3"
require "shellwords"

module Hanami
  module Assets
    # Precompile all the assets, coming from all the applications and third
    # party gems into the public directory of the project.
    #
    # @since 0.1.0
    # @api private
    class Precompiler
      def initialize(configuration:)
        @configuration = configuration
      end

      def call
        execute(cmd, *args)
      end

      private

      attr_reader :configuration

      def execute(command, *arguments)
        _, stderr, result = Open3.capture3(command, *arguments)

        raise PrecompileError.new(stderr) unless result.success?

        true
      end

      def cmd
        configuration.esbuild
      end

      def args
        entry_points + flags
      end

      def entry_points
        configuration.entry_points
      end

      def flags
        [
          "--bundle",
          "--minify",
          "--sourcemap",
          "--outdir=#{destination}",
          "--entry-names=[dir]/[name]-[hash]"
        ]
      end

      def destination
        Shellwords.shellescape(configuration.destination)
      end
    end
  end
end
