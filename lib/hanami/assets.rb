# frozen_string_literal: true

require "json"

# Hanami
#
# @since 0.1.0
module Hanami
  # Assets management for Ruby web applications
  #
  # @since 0.1.0
  class Assets
    require "hanami/assets/version"
    require "hanami/assets/asset"
    require "hanami/assets/errors"
    require "hanami/assets/config"

    # @since 2.1.0
    # @api private
    SEPARATOR = "/"
    private_constant :SEPARATOR

    attr_reader :config

    # @since 2.1.0
    # @api public
    def initialize(config:)
      @config = config
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
          {path: config.path_prefix + SEPARATOR + path}
        end

      Asset.new(
        **asset_attrs,
        base_url: config.base_url
      )
    end

    # @since 2.1.0
    # @api public
    def subresource_integrity?
      config.subresource_integrity.any?
    end

    # @since 2.1.0
    # @api public
    def crossorigin?(source_path)
      config.crossorigin?(source_path)
    end

    private

    def manifest
      return @manifest if instance_variable_defined?(:@manifest)

      @manifest =
        # TODO: Add tests for the File.exist? check
        if config.manifest_path && File.exist?(config.manifest_path)
          JSON.parse(File.read(config.manifest_path))
        end
    end

    def manifest?
      !!manifest
    end
  end
end
