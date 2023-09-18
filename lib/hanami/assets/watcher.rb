# frozen_string_literal: true

require "shellwords"

module Hanami
  class Assets
    # @since 2.1.0
    # @api private
    class Watcher
      # @since 2.1.0
      # @api private
      attr_reader :config
      private :config

      # @since 2.1.0
      # @api private
      def initialize(config:)
        super()
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
        pid = Process.spawn(environment, command, *arguments)

        # Avoid zombie children processes
        # See https://ruby-doc.org/core/Process.html#method-c-detach
        Process.detach(pid)

        true
      end

      # @since 2.1.0
      # @api private
      def cmd_with_args
        [
          config.package_manager_executable,
          config.package_manager_command,
          config.executable,
          "--",
          "--watch"
        ]
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
