require 'lotus/assets/version'
require 'lotus/assets/assets_helpers'

require 'lotus/utils/class_attribute'

module Lotus
  module Assets
    include Utils::ClassAttribute

    class << self
      attr_accessor :path, :css_engine, :js_engine
    end
  end
end
