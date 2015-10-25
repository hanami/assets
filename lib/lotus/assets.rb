require 'lotus/assets/version'
require 'lotus/assets/configuration'
require 'lotus/assets/config/global_sources'
require 'lotus/assets/helpers'
require 'lotus/utils/class_attribute'

module Lotus
  module Assets
    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end

    def self.sources
      @@sources ||= Config::GlobalSources.new
    end

    def self.duplicate(mod, assets = 'Assets', &blk)
      dupe.tap do |duplicated|
        # mod.module_eval %{ module #{ assets }; end } if assets
        # mod.module_eval %{ Assets = Lotus::Assets.dup unless defined?(#{ mod }::Assets) } unless assets.nil?

        # duplicated.module_eval %{
        #   configure do
        #     action_module #{ mod }::Action
        #   end
        # }

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
      @@duplicates ||= Array.new
    end
  end
end
