# frozen_string_literal: true

require "shellwords"

module Hanami
  module Assets
    # @since 2.1.0
    # @api private
    class Watcher
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
        pid = Process.spawn(environment, command, *arguments)

        # Avoid zombie children processes
        # See https://ruby-doc.org/core/Process.html#method-c-detach
        Process.detach(pid)

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
        [
          configuration.esbuild_script,
          "--watch"
        ]
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
