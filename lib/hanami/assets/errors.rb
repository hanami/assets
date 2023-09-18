# frozen_string_literal: true

module Hanami
  class Assets
    # Base error for Hanami::Assets
    #
    # All the errors defined in this framework MUST inherit from it.
    #
    # @since 0.1.0
    class Error < ::StandardError
    end
  end
end
