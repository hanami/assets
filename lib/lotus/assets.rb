require 'lotus/assets/version'
require 'lotus/assets/configuration'
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
  end
end
