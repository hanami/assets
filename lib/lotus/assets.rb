require 'lotus/assets/version'
require 'lotus/assets/assets_helpers'

module Lotus
  module Assets
    class << self
      attr_accessor :path
    end
  end
end
