require 'lotus/assets/version'
require 'lotus/assets/assets_helpers'

module Lotus
  module Assets
    class << self
      attr_accessor :path
      attr_writer :css_engine, :js_engine, :stylesheet_path, :javascript_path

      def css_engine
        @css_engine || 'scss'
      end

      def js_engine
        @js_engine || 'coffee'
      end

      def stylesheet_path
        @stylesheet_path || 'stylesheets'
      end

      def javascript_path
        @javascript_path || 'javascripts'
      end
    end
  end
end
