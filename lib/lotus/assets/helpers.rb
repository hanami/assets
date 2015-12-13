require 'uri'
require 'set'
require 'thread'
require 'lotus/helpers/html_helper'
require 'lotus/utils/escape'

module Lotus
  module Assets
    module Helpers
      NEW_LINE_SEPARATOR = "\n".freeze

      WILDCARD_EXT = '.*'.freeze

      JAVASCRIPT_EXT = '.js'.freeze
      STYLESHEET_EXT = '.css'.freeze

      JAVASCRIPT_MIME_TYPE = 'text/javascript'.freeze
      STYLESHEET_MIME_TYPE = 'text/css'.freeze
      FAVICON_MIME_TYPE    = 'image/x-icon'.freeze

      STYLESHEET_REL  = 'stylesheet'.freeze
      FAVICON_REL     = 'shortcut icon'.freeze

      DEFAULT_FAVICON = 'favicon.ico'.freeze

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

      # Creates a img tag. Takes the asset path as the first parameter.
      # Alt attribute is auto-calculated as the titleized path of the asset.
      # Any other parameter will be output as an attribute of the img tag.
      #
      # @since x.x.x
      # @api public
      #
      # @example Usage in view.
      #
      #   module Web::Views::Home
      #     include Lotus::View
      #
      #     def avatar(user)
      #       image("user_#{user.id}_avatar", id: user.id, class: 'user-avatar')
      #     end
      #   end
      #
      #   This method will output:
      #   => <img src='/assets/user_1_avatar' alt='User 1 avatar' id='1' class='user-avatar'>
      #
      #
      def image(source, options = {})
        options[:src] = asset_path(source)
        options[:alt] ||= Utils::String.new(::File.basename(source, WILDCARD_EXT)).titleize

        html.img(options)
      end

      # Creates a link tag for a favicon.
      #
      # @since x.x.x
      # @api public
      #
      # @example Basic usage
      #   <%= favicon %>
      #     # => <link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example HTML attributes
      #  <%= favicon('favicon.png', rel: 'icon', type: 'image/png') %>
      #    # => <link rel="icon" type="image/png" href="/assets/favicon.png">
      def favicon(source = DEFAULT_FAVICON, options = {})
        options[:href]   = asset_path(source)
        options[:rel]  ||= FAVICON_REL
        options[:type] ||= FAVICON_MIME_TYPE

        html.link(options)
      end

      # Generates a video tag for the given arguments.
      #
      # @raise [ArgumentError] if the signature isn't respected
      # @since x.x.x
      # @api public
      #
      # @example Basic usage
      #   <%= video('movie.mp4') %>
      #     # => <video src="/assets/movie.mp4"></video>
      #
      # @example HTML attributes
      #   <%= video('movie.mp4', autoplay: true, controls: true) %>
      #     # => <video src="/assets/movie.mp4" autoplay="autoplay" controls="controls"></video>
      #
      # @example Fallback Content
      #   <%=
      #     video('movie.mp4') do
      #       "Your browser does not support the video tag"
      #     end
      #   %>
      #     # => <video src="/assets/movie.mp4">\nYour browser does not support the video tag\n</video>
      #
      # @example Tracks
      #   <%=
      #     video('movie.mp4') do
      #       track kind: 'captions', src: view.asset_path('movie.en.vtt'), srclang: 'en', label: 'English'
      #     end
      #   %>
      #     # => <video src="/assets/movie.mp4">\n<track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">\n</video>
      #
      # @example Sources
      #   <%=
      #     video do
      #       text "Your browser does not support the video tag"
      #       source src: view.asset_path('movie.mp4'), type: 'video/mp4'
      #       source src: view.asset_path('movie.ogg'), type: 'video/ogg'
      #     end
      #   %>
      #     # => <video>\nYour browser does not support the video tag\n<source src="/assets/movie.mp4" type="video/mp4">\n<source src="/assets/movie.ogg" type="video/ogg">\n</video>
      #
      # @example Without any argument
      #   <%= video %>
      #     # => ArgumentError
      #
      # @example Without src and without block
      #   <%= video(content: true) %>
      #     # => ArgumentError
      def video(src = nil, options = {}, &blk)
        options ||= {}

        if src.respond_to?(:to_hash)
          options = src.to_hash
        elsif src
          options[:src] = asset_path(src)
        end

        if !options[:src] && !block_given?
          raise ArgumentError.new('You should provide a source via `src` option or with a `source` HTML tag')
        end

        html.video(blk, options)
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
