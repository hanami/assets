# frozen_string_literal: true

module Hanami
  class Assets
    # Base error for Hanami::Assets.
    #
    # @api public
    # @since 0.1.0
    class Error < ::StandardError
    end

    # Error returned when the assets manifest file is missing.
    #
    # @api public
    # @since 2.1.0
    class ManifestMissingError < Error
      def initialize(manifest_path)
        super(<<~TEXT)
          Missing manifest file at #{manifest_path.inspect}

          Have you run `hanami assets compile` or `hanami assets watch`?
        TEXT
      end
    end

    # Error raised when no asset can be found for a source path.
    #
    # @api public
    # @since 2.1.0
    class AssetMissingError < Error
      def initialize(source_path)
        super(<<~TEXT)
          No asset found for #{source_path.inspect}
        TEXT
      end
    end
  end
end
