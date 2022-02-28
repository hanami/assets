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
        execute(cmd, *args)
      end

      private

      attr_reader :configuration

      def execute(command, *arguments)
        pid = Process.spawn(command, *arguments)

        # Avoid zombie children processes
        # See https://ruby-doc.org/core/Process.html#method-c-spawn
        Process.detach(pid)

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
          "--watch",
          "--bundle",
          "--log-level=silent",
          "--outdir=#{destination}"
        ]
      end

      def destination
        Shellwords.shellescape(configuration.destination)
      end
    end
  end
end
