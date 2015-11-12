require 'lotus/assets/version'
require 'lotus/assets/configuration'
require 'lotus/assets/config/global_sources'
require 'lotus/assets/helpers'
require 'lotus/utils/class_attribute'
require 'thread'

module Lotus
  module Assets
    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    def self.configure(&blk)
      configuration.instance_eval(&blk)
      self
    end

    def self.deploy
      require 'lotus/assets/precompiler'
      require 'lotus/assets/bundler'

      Precompiler.new(configuration, duplicates).run
      Bundler.new(configuration).run
    end

    def self.load!
      configuration.load!
    end

    def self.sources
      synchronize do
        @@sources ||= Config::GlobalSources.new
      end
    end

    def self.duplicate(mod, &blk)
      dupe.tap do |duplicated|
        duplicated.configure(&blk) if block_given?
        duplicates << duplicated
      end
    end

    def self.dupe
      dup.tap do |duplicated|
        duplicated.configuration = configuration.duplicate
      end
    end

    def self.duplicates
      synchronize do
        @@duplicates ||= Array.new
      end
    end

    private

    def self.synchronize(&blk)
      Mutex.new.synchronize(&blk)
    end
  end
end
