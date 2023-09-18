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

    # Error raised when assets config is not valid.
    #
    # @since 2.1.0
    # @api public
    class ConfigError < Error
    end

    # Error returned when the assets manifest file is missing.
    #
    # @since 2.1.0
    # @api public
    class ManifestMissingError < Error
      def initialize(manifest_path)
        super(<<~TEXT)
          Missing manifest file at #{manifest_path}.

          Have you run `hanami assets compile` or `hanami assets watch`?
        TEXT
      end
    end
  end
end
