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
        super()
        @configuration = configuration

        freeze
      end

      def call
        execute(cmd, env, *args)
      end

      private

      attr_reader :configuration

      def execute(command, environment, *arguments)
        _, stderr, result = Open3.capture3(environment, command, *arguments)

        raise PrecompileError.new(stderr) unless result.success?

        true
      end

      def cmd
        "node"
      end

      def env
        ENV.to_h.merge({
                         "ESBUILD_ENTRY_POINTS" => entry_points,
                         "ESBUILD_OUTDIR" => destination
                       })
      end

      def args
        [
          configuration.esbuild_script,
          "--precompile"
        ]
      end

      # config.assets do |c|
      #   c.entry_points = [
      #     "app/assets/*/*.#{extensions}",
      #     "slices/*/assets/*/*.#{extensions}"
      #   ]
      # end

      def entry_points
        configuration.entry_points.map do |entry_point|
          escape(entry_point)
        end.join(" ")
      end

      def destination
        escape(configuration.destination)
      end

      def escape(str)
        Shellwords.shellescape(str)
      end
    end
  end
end
