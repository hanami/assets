# frozen_string_literal: true

require_relative "cli_command"

module Hanami
  class Assets
    # @since 2.1.0
    # @api private
    class Watcher < CLICommand
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
        super +
          [
            "--",
            "--watch"
          ]
      end
    end
  end
end
