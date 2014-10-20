require 'lotus/utils/class_attribute'

require 'lotus/assets/version'
require 'lotus/assets/helpers'
require 'lotus/assets/dsl'
require 'lotus/assets/configuration'

module Lotus
  module Assets
    include Utils::ClassAttribute

    class_attribute :configuration
    self.configuration = Configuration.new

    def self.included(base)
      base.include(Helpers)
    end

    def self.configure(&blk)
      configuration.instance_eval(&blk)
    end
  end
end
