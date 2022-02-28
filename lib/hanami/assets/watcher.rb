# frozen_string_literal: true

require "shellwords"

module Hanami
  module Assets
    class Watcher
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
        pid = Process.spawn(environment, command, *arguments)

        # Avoid zombie children processes
        # See https://ruby-doc.org/core/Process.html#method-c-spawn
        Process.detach(pid)

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
          "--watch"
        ]
      end

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
