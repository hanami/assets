# frozen_string_literal: true

require "hanami/cyg_utils/class_attribute"

# Hanami
#
# @since 0.1.0
module Hanami
  # Assets management for Ruby web applications
  #
  # @since 0.1.0
  module Assets
    # Base error for Hanami::Assets
    #
    # All the errors defined in this framework MUST inherit from it.
    #
    # @since 0.1.0
    class Error < ::StandardError
    end

    require "hanami/assets/version"
    require "hanami/assets/configuration"
    require "hanami/assets/config/global_sources"
    require "hanami/assets/helpers"

    include CygUtils::ClassAttribute

    # Configuration
    #
    # @since 0.1.0
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure framework
    #
    # @param blk [Proc] configuration code block
    #
    # @return self
    #
    # @since 0.1.0
    #
    # @see Hanami::Assets::Configuration
    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    # Prepare assets for deploys
    #
    # @since 0.1.0
    def self.deploy
      require "hanami/assets/precompiler"
      require "hanami/assets/bundler"

      Precompiler.new(configuration, duplicates).run
      Bundler.new(configuration,     duplicates).run
    end

    # Precompile assets
    #
    # @since 0.4.0
    def self.precompile(configurations)
      require "hanami/assets/precompiler"
      require "hanami/assets/bundler"

      Precompiler.new(configuration, configurations).run
      Bundler.new(configuration,     configurations).run
    end

    # Preload the framework
    #
    # This MUST be used in production mode
    #
    # @since 0.1.0
    #
    # @example Direct Invocation
    #   require 'hanami/assets'
    #
    #   Hanami::Assets.load!
    #
    # @example Load Via Configuration Block
    #   require 'hanami/assets'
    #
    #   Hanami::Assets.configure do
    #     # ...
    #   end.load!
    def self.load!
      configuration.load!
    end

    # Global assets sources
    #
    # This is designed for third party integration gems with frontend frameworks
    # like Bootstrap, Ember.js or React.
    #
    # Developers can maintain gems that ship static assets for these frameworks
    # and make them available to Hanami::Assets.
    #
    # @return [Hanami::Assets::Config::GlobalSources]
    #
    # @since 0.1.0
    #
    # @example Ember.js Integration
    #   # lib/hanami/emberjs.rb (third party gem)
    #   require 'hanami/assets'
    #
    #   Hanami::Assets.sources << '/path/to/emberjs/assets'
    def self.sources
      synchronize do
        @@sources ||= Config::GlobalSources.new # rubocop:disable Style/ClassVars
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param _mod [Module] the Ruby namespace of the application
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Hanami::Assets
    #
    # @since 0.1.0
    #
    # @see Hanami::Assets#dupe
    # @see Hanami::Assets::Configuration
    def self.duplicate(_mod, &blk)
      dupe.tap do |duplicated|
        duplicated.configure(&blk) if block_given?
        duplicates << duplicated
      end
    end

    # Duplicate Hanami::Assets in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Hanami::Assets
    #
    # @since 0.1.0
    # @api private
    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    # Keep track of duplicated frameworks
    #
    # @return [Array] a collection of duplicated frameworks
    #
    # @since 0.1.0
    # @api private
    #
    # @see Hanami::Assets#duplicate
    # @see Hanami::Assets#dupe
    def self.duplicates
      synchronize do
        @@duplicates ||= [] # rubocop:disable Style/ClassVars
      end
    end

    class << self
      private

      # @since 0.1.0
      # @api private
      def synchronize(&blk)
        Mutex.new.synchronize(&blk)
      end
    end
  end
end
