# frozen_string_literal: true

require "json"
require "pathname"
require "zeitwerk"

module Hanami
  # Assets management for Ruby web applications
  #
  # @since 0.1.0
  class Assets
    # @since 2.1.0
    # @api private
    def self.gem_loader
      @gem_loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)
        loader.tag = "hanami-assets"
        loader.push_dir(root)
        loader.ignore(
          "#{root}/hanami-assets.rb",
          "#{root}/hanami/assets/version.rb",
          "#{root}/hanami/assets/errors.rb"
        )
        loader.inflector = Zeitwerk::GemInflector.new("#{root}/hanami-assets.rb")
      end
    end

    gem_loader.setup
    require_relative "assets/version"
    require_relative "assets/errors"

    # @api private
    # @since 2.1.0
    SEPARATOR = "/"
    private_constant :SEPARATOR

    # @api private
    # @since 2.1.0
    attr_reader :config

    # @api private
    # @since 2.1.0
    attr_reader :root

    # @api public
    # @since 2.1.0
    def initialize(config:, root:)
      @config = config
      @root = Pathname(root)
    end

    # Returns the asset at the given path.
    #
    # @return [Hanami::Assets::Asset] the asset
    #
    # @raise AssetMissingError if no asset can be found at the path
    #
    # @api public
    # @since 2.1.0
    def [](path)
      asset_attrs = manifest
        .fetch(path) { raise AssetMissingError.new(path) }
        .transform_keys(&:to_sym)
        .tap { |attrs|
          # The `url` attribute we receive from the manifest is actually a path; rename it as such
          # so our `Asset` attributes make more sense on their own.
          attrs[:path] = attrs.delete(:url)
        }

      Asset.new(
        **asset_attrs,
        base_url: config.base_url
      )
    end

    # Returns true if subresource integrity is configured.
    #
    # @return [Boolean]
    #
    # @api public
    # @since 2.1.0
    def subresource_integrity?
      config.subresource_integrity.any?
    end

    # Returns true if the given source path is a cross-origin request.
    #
    # @return [Boolean]
    #
    # @api public
    # @since 2.1.0
    def crossorigin?(source_path)
      config.crossorigin?(source_path)
    end

    private

    def manifest
      return @manifest if instance_variable_defined?(:@manifest)

      full_manifest_path = root.join(config.manifest_path)

      unless full_manifest_path.exist?
        raise ManifestMissingError.new(full_manifest_path.to_s)
      end

      @manifest = JSON.parse(File.read(full_manifest_path))
    end
  end
end
