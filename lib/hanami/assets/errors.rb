# frozen_string_literal: true

module Hanami
  module Assets
    # Base error for Hanami::Assets
    #
    # All the errors defined in this framework MUST inherit from it.
    #
    # @since 0.1.0
    class Error < ::StandardError
    end

    # @since 2.0.0
    class PrecompileError < Error
    end
  end
end
