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
        if manifest?
          manifest.fetch(path)
        else
          {"url" => configuration.path_prefix + SEPARATOR + path}
        end
      end

      # @since 2.1.0
      # @api public
      def asset_path(path)
        configuration.base_url.join(self[path].fetch("url"))
      end

      # @since 2.1.0
      # @api public
      def subresource_integrity_value(path)
        self[path].fetch("sri")
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
