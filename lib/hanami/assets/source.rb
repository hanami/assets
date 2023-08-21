# frozen_string_literal: true

require "json"

module Hanami
  module Assets
    # Assets source
    #
    # @since 2.1.0
    # @api public
    class Source
      # @since 2.1.0
      # @api private
      SEPARATOR = "/"
      private_constant :SEPARATOR

      attr_reader :configuration

      # @since 2.1.0
      # @api public
      def initialize(configuration:)
        @configuration = configuration
      end

      # @since 2.1.0
      # @api public
      def [](path)
        asset_attrs =
          if manifest?
            manifest.fetch(path).transform_keys(&:to_sym).tap { |attrs|
              # The `url` attribute we receive from the manifest is actually a path; rename it as
              # such so our `Asset` attributes make more sense on their own.
              attrs[:path] = attrs.delete(:url)
            }
          else
            {path: configuration.path_prefix + SEPARATOR + path}
          end

        Asset.new(configuration: configuration, **asset_attrs)
      end

      private

      def manifest?
        !!manifest
      end

      def manifest
        return @manifest if instance_variable_defined?(:@manifest)

        @manifest =
          if configuration.manifest_path
            JSON.parse(File.read(configuration.manifest_path))
          end
      end
    end
  end
end
