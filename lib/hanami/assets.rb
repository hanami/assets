# frozen_string_literal: true

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
    require "hanami/assets/configuration"
    require "hanami/assets/helpers"

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

    def manifest
      return @manifest if instance_variable_defined?(:@manifest)

      @manifest =
        if configuration.manifest_path
          JSON.parse(File.read(configuration.manifest_path))
        end
    end

    def manifest?
      !!manifest
    end
  end
end
