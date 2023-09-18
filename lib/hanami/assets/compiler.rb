# frozen_string_literal: true

require "open3"
require_relative "cli_command"

module Hanami
  class Assets
    # Compile all the assets, coming from all the applications and third
    # party gems into the public directory of the project.
    #
    # @since 2.1.0
    # @api private
    class Compiler < CLICommand
      private

      # @since 2.1.0
      # @api private
      def execute(command, environment, *arguments)
        _, stderr, result = Open3.capture3(environment, command, *arguments)

        raise CompileError.new(stderr) unless result.success?

        true
      end

      # @since 2.1.0
      # @api private
      def cmd_with_args
        result = super

        if config.subresource_integrity.any?
          result << "--"
          result << "--sri=#{config.subresource_integrity.join(',')}"
        end

        result
      end
    end
  end
end
