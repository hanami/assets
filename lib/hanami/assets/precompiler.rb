# frozen_string_literal: true

require "open3"
require "shellwords"

module Hanami
  class Assets
    # Precompile all the assets, coming from all the applications and third
    # party gems into the public directory of the project.
    #
    # @since 0.1.0
    # @api private
    class Precompiler
      # @since 2.1.0
      # @api private
      attr_reader :config
      private :config

      # @since 2.1.0
      # @api private
      def initialize(config:)
        @config = config

        freeze
      end

      # @since 2.1.0
      # @api private
      def call
        cmd, *args = cmd_with_args
        execute(cmd, env, *args)
      end

      private

      # @since 2.1.0
      # @api private
      def execute(command, environment, *arguments)
        _, stderr, result = Open3.capture3(environment, command, *arguments)

        raise PrecompileError.new(stderr) unless result.success?

        true
      end

      # @since 2.1.0
      # @api private
      def cmd_with_args
        result = [
          config.package_manager_executable,
          config.package_manager_command,
          config.executable
        ]

        if config.subresource_integrity.any?
          result << "--"
          result << "--sri=#{config.subresource_integrity.join(',')}"
        end

        result
      end

      # @since 2.1.0
      # @api private
      def env
        ENV.to_h.merge(
          "ESBUILD_ENTRY_POINTS" => entry_points,
          "ESBUILD_OUTDIR" => destination
        )
      end

      # @since 2.1.0
      # @api private
      def entry_points
        config.entry_points.map do |entry_point|
          escape(entry_point)
        end.join(" ")
      end

      # @since 2.1.0
      # @api private
      def destination
        escape(config.destination)
      end

      # @since 2.1.0
      # @api private
      def escape(str)
        Shellwords.shellescape(str)
      end
    end
  end
end
