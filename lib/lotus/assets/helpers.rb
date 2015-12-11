require 'uri'
require 'set'
require 'thread'
require 'lotus/helpers/html_helper'
require 'lotus/utils/escape'

module Lotus
  module Assets
    module Helpers
      NEW_LINE_SEPARATOR = "\n".freeze

      JAVASCRIPT_EXT = '.js'.freeze
      STYLESHEET_EXT = '.css'.freeze

      JAVASCRIPT_MIME_TYPE = 'text/javascript'.freeze
      STYLESHEET_MIME_TYPE = 'text/css'.freeze

      STYLESHEET_REL = 'stylesheet'.freeze

      include Lotus::Helpers::HtmlHelper

      def self.included(base)
        conf = ::Lotus::Assets::Configuration.for(base)
        base.class_eval do
          include Utils::ClassAttribute

          class_attribute :assets_configuration
          self.assets_configuration = conf
        end
      end

      def javascript(*sources)
        _safe_tags(*sources) do |source|
          html.script(src: _typed_asset_path(source, JAVASCRIPT_EXT), type: JAVASCRIPT_MIME_TYPE).to_s
        end
      end

      def stylesheet(*sources)
        _safe_tags(*sources) do |source|
          html.link(href: _typed_asset_path(source, STYLESHEET_EXT), type: STYLESHEET_MIME_TYPE, rel: STYLESHEET_REL).to_s
        end
      end

      def asset_path(source)
        _push_promise(
          _absolute_url?(source) ?
            source : _relative_path(source)
        )
      end

      private

      def _safe_tags(*sources)
        ::Lotus::Utils::Escape::SafeString.new(
          sources.map do |source|
            yield source
          end.join(NEW_LINE_SEPARATOR)
        )
      end

      def _typed_asset_path(source, ext)
        source = "#{ source }#{ ext }" unless source.match(/#{ Regexp.escape(ext) }\z/)
        asset_path(source)
      end

      def _absolute_url?(source)
        URI.regexp.match(source)
      end

      def _relative_path(source)
        self.class.assets_configuration.asset_path(source)
      end

      def _push_promise(url)
        Mutex.new.synchronize do
          Thread.current[:__lotus_assets] ||= Set.new
          Thread.current[:__lotus_assets].add(url.to_s)
        end

        url
      end
    end
  end
end
