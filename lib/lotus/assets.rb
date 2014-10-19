require 'lotus/assets/version'
require 'lotus/assets/assets_helpers'

module Lotus
  module Assets
    class << self
      attr_accessor :path
      attr_writer :css_engine, :js_engine

      def css_engine
        @css_engine || 'scss'
      end

      def js_engine
        @js_engine || 'coffee'
      end
    end
  end
end
