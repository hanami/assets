require 'thread'
require 'lotus/utils/class_attribute'

module Lotus
  # Assets management for Ruby web applications
  #
  # @since x.x.x
  module Assets
    # Base error for Lotus::Assets
    #
    # All the errors defined in this framework MUST inherit from it.
    #
    # @since x.x.x
    class Error < ::StandardError
    end

    require 'lotus/assets/version'
    require 'lotus/assets/configuration'
    require 'lotus/assets/config/global_sources'
    require 'lotus/assets/helpers'

    include Utils::ClassAttribute

    # Configuration
    #
    # @since x.x.x
    # @api private
    class_attribute :configuration
    self.configuration = Configuration.new

    # Configure framework
    #
    # @param blk [Proc] configuration code block
    #
    # @return self
    #
    # @since x.x.x
    #
    # @see Lotus::Assets::Configuration
    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    # Prepare assets for deploys
    #
    # @since x.x.x
    def self.deploy
      require 'lotus/assets/precompiler'
      require 'lotus/assets/bundler'

      Precompiler.new(configuration, duplicates).run
      Bundler.new(configuration,     duplicates).run
    end

    # Preload the framework
    #
    # This MUST be used in production mode
    #
    # @since x.x.x
    #
    # @example Direct Invocation
    #   require 'lotus/assets'
    #
    #   Lotus::Assets.load!
    #
    # @example Load Via Configuration Block
    #   require 'lotus/assets'
    #
    #   Lotus::Assets.configure do
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
    # and make them available to Lotus::Assets.
    #
    # @return [Lotus::Assets::Config::GlobalSources]
    #
    # @since x.x.x
    #
    # @example Ember.js Integration
    #   # lib/lotus/emberjs.rb (third party gem)
    #   require 'lotus/assets'
    #
    #   Lotus::Assets.sources << '/path/to/emberjs/assets'
    def self.sources
      synchronize do
        @@sources ||= Config::GlobalSources.new
      end
    end

    # Duplicate the framework and generate modules for the target application
    #
    # @param mod [Module] the Ruby namespace of the application
    # @param blk [Proc] an optional block to configure the framework
    #
    # @return [Module] a copy of Lotus::Assets
    #
    # @since x.x.x
    #
    # @see Lotus::Assets#dupe
    # @see Lotus::Assets::Configuration
    def self.duplicate(mod, &blk)
      dupe.tap do |duplicated|
        duplicated.configure(&blk) if block_given?
        duplicates << duplicated
      end
    end

    # Duplicate Lotus::Assets in order to create a new separated instance
    # of the framework.
    #
    # The new instance of the framework will be completely decoupled from the
    # original. It will inherit the configuration, but all the changes that
    # happen after the duplication, won't be reflected on the other copies.
    #
    # @return [Module] a copy of Lotus::Assets
    #
    # @since x.x.x
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
    # @since x.x.x
    # @api private
    #
    # @see Lotus::Assets#duplicate
    # @see Lotus::Assets#dupe
    def self.duplicates
      synchronize do
        @@duplicates ||= Array.new
      end
    end

    private

    # @since x.x.x
    # @api private
    def self.synchronize(&blk)
      Mutex.new.synchronize(&blk)
    end
  end
end
