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
      # @since 2.1.0
      # @api private
      def initialize(configuration:)
        super()
        @configuration = configuration

        freeze
      end

      # @since 2.1.0
      # @api private
      def call
        execute(cmd, env, *args)
      end

      private

      # @since 2.1.0
      # @api private
      attr_reader :configuration

      # @since 2.1.0
      # @api private
      def execute(command, environment, *arguments)
        _, stderr, result = Open3.capture3(environment, command, *arguments)

        raise PrecompileError.new(stderr) unless result.success?

        true
      end

      # @since 2.1.0
      # @api private
      def cmd
        "node"
      end

      # @since 2.1.0
      # @api private
      def env
        ENV.to_h.merge({
          "ESBUILD_ENTRY_POINTS" => entry_points,
          "ESBUILD_OUTDIR" => destination
        })
      end

      # @since 2.1.0
      # @api private
      def args
        result = [
          configuration.esbuild_script,
          "--precompile"
        ]

        if configuration.subresource_integrity.any?
          result << "--sri=#{configuration.subresource_integrity.join(",")}"
        end

        result
      end

      # @since 2.1.0
      # @api private
      def entry_points
        configuration.entry_points.map do |entry_point|
          escape(entry_point)
        end.join(" ")
      end

      # @since 2.1.0
      # @api private
      def destination
        escape(configuration.destination)
      end

      # @since 2.1.0
      # @api private
      def escape(str)
        Shellwords.shellescape(str)
      end
    end
  end
end
