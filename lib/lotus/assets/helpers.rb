require 'uri'
require 'set'
require 'thread'
require 'lotus/helpers/html_helper'
require 'lotus/utils/escape'

module Lotus
  module Assets
    # HTML assets helpers
    #
    # @since x.x.x
    #
    # @see http://www.rubydoc.info/gems/lotus-helpers/Lotus/Helpers/HtmlHelper
    module Helpers
      # @since x.x.x
      # @api private
      NEW_LINE_SEPARATOR = "\n".freeze

      # @since x.x.x
      # @api private
      WILDCARD_EXT   = '.*'.freeze

      # @since x.x.x
      # @api private
      JAVASCRIPT_EXT = '.js'.freeze

      # @since x.x.x
      # @api private
      STYLESHEET_EXT = '.css'.freeze

      # @since x.x.x
      # @api private
      JAVASCRIPT_MIME_TYPE = 'text/javascript'.freeze

      # @since x.x.x
      # @api private
      STYLESHEET_MIME_TYPE = 'text/css'.freeze

      # @since x.x.x
      # @api private
      FAVICON_MIME_TYPE    = 'image/x-icon'.freeze

      # @since x.x.x
      # @api private
      STYLESHEET_REL  = 'stylesheet'.freeze

      # @since x.x.x
      # @api private
      FAVICON_REL     = 'shortcut icon'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_FAVICON = 'favicon.ico'.freeze

      include Lotus::Helpers::HtmlHelper

      # Inject helpers into the given class
      #
      # @since x.x.x
      # @api private
      def self.included(base)
        conf = ::Lotus::Assets::Configuration.for(base)
        base.class_eval do
          include Utils::ClassAttribute

          class_attribute :assets_configuration
          self.assets_configuration = conf
        end
      end

      # Generate <tt>script</tt> tag for given source(s)
      #
      # It accepts one or more strings representing the name of the asset, if it
      # comes from the application or third party gems. It also accepts strings
      # representing absolute URLs in case of public CDN (eg. jQuery CDN).
      #
      # If the "digest mode" is on, <tt>src</tt> is the digest version of the
      # relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # @param sources [Array<String>] one or more assets by name or absolute URL
      #
      # @return [Lotus::Utils::Escape::SafeString] the markup
      #
      # @raise [Lotus::Assets::MissingDigestAssetError] if digest mode is on and
      #   at least one of the given sources is missing
      #
      # @since x.x.x
      #
      # @see Lotus::Assets::Configuration#digest
      # @see Lotus::Assets::Configuration#cdn
      # @see Lotus::Assets::Helpers#asset_path
      #
      # @example Single Asset
      #
      #   <%= javascript 'application' %>
      #
      #   # <script src="/assets/application.js" type="text/javascript"></script>
      #
      # @example Multiple Assets
      #
      #   <%= javascript 'application', 'dashboard' %>
      #
      #   # <script src="/assets/application.js" type="text/javascript"></script>
      #   # <script src="/assets/dashboard.js" type="text/javascript"></script>
      #
      # @example Absolute URL
      #
      #   <%= javascript 'https://code.jquery.com/jquery-2.1.4.min.js' %>
      #
      #   # <script src="https://code.jquery.com/jquery-2.1.4.min.js" type="text/javascript"></script>
      #
      # @example Digest Mode
      #
      #   <%= javascript 'application' %>
      #
      #   # <script src="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js" type="text/javascript"></script>
      #
      # @example CDN Mode
      #
      #   <%= javascript 'application' %>
      #
      #   # <script src="https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js" type="text/javascript"></script>
      def javascript(*sources)
        _safe_tags(*sources) do |source|
          html.script(src: _typed_asset_path(source, JAVASCRIPT_EXT), type: JAVASCRIPT_MIME_TYPE).to_s
        end
      end

      # Generate <tt>link</tt> tag for given source(s)
      #
      # It accepts one or more strings representing the name of the asset, if it
      # comes from the application or third party gems. It also accepts strings
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # If the "digest mode" is on, <tt>href</tt> is the digest version of the
      # relative URL.
      #
      # If the "CDN mode" is on, the <tt>href</tt> is an absolute URL of the
      # application CDN.
      #
      # @param sources [Array<String>] one or more assets by name or absolute URL
      #
      # @return [Lotus::Utils::Escape::SafeString] the markup
      #
      # @raise [Lotus::Assets::MissingDigestAssetError] if digest mode is on and
      #   at least one of the given sources is missing
      #
      # @since x.x.x
      #
      # @see Lotus::Assets::Configuration#digest
      # @see Lotus::Assets::Configuration#cdn
      # @see Lotus::Assets::Helpers#asset_path
      #
      # @example Single Asset
      #
      #   <%= stylesheet 'application' %>
      #
      #   # <link href="/assets/application.css" type="text/css" rel="stylesheet">
      #
      # @example Multiple Assets
      #
      #   <%= stylesheet 'application', 'dashboard' %>
      #
      #   # <link href="/assets/application.css" type="text/css" rel="stylesheet">
      #   # <link href="/assets/dashboard.css" type="text/css" rel="stylesheet">
      #
      # @example Absolute URL
      #
      #   <%= stylesheet 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css' %>
      #
      #   # <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" type="text/css" rel="stylesheet">
      #
      # @example Digest Mode
      #
      #   <%= stylesheet 'application' %>
      #
      #   # <link href="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css" type="text/css" rel="stylesheet">
      #
      # @example CDN Mode
      #
      #   <%= stylesheet 'application' %>
      #
      #   # <link href="https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css" type="text/css" rel="stylesheet">
      def stylesheet(*sources)
        _safe_tags(*sources) do |source|
          html.link(href: _typed_asset_path(source, STYLESHEET_EXT), type: STYLESHEET_MIME_TYPE, rel: STYLESHEET_REL).to_s
        end
      end

      # Generate <tt>img</tt> tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # <tt>alt</tt> Attribute is auto generated from <tt>src</tt>.
      # You can specify a different value, by passing the <tt>:src</tt> option.
      #
      # If the "digest mode" is on, <tt>src</tt> is the digest version of the
      # relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # @param sources [String] asset name or absolute URL
      #
      # @return [Lotus::Utils::Helpers::HtmlBuilder] the builder
      #
      # @raise [Lotus::Assets::MissingDigestAssetError] if digest mode is on and
      #   at least one of the given sources is missing
      #
      # @since x.x.x
      #
      # @see Lotus::Assets::Configuration#digest
      # @see Lotus::Assets::Configuration#cdn
      # @see Lotus::Assets::Helpers#asset_path
      #
      # @example Basic Usage
      #
      #   <%= image 'logo.png' %>
      #
      #   # <img src="/assets/logo.png" alt="Logo">
      #
      # @example Custom alt Attribute
      #
      #   <%= image 'logo.png', alt: 'Application Logo' %>
      #
      #   # <img src="/assets/logo.png" alt="Application Logo">
      #
      # @example Custom HTML Attributes
      #
      #   <%= image 'logo.png', id: 'logo', class: 'image' %>
      #
      #   # <img src="/assets/logo.png" alt="Logo" id="logo" class="image">
      #
      # @example Absolute URL
      #
      #   <%= image 'https://example-cdn.com/images/logo.png' %>
      #
      #   # <img src="https://example-cdn.com/images/logo.png" alt="Logo">
      #
      # @example Digest Mode
      #
      #   <%= image 'logo.png' %>
      #
      #   # <img src="/assets/logo-28a6b886de2372ee3922fcaf3f78f2d8.png" alt="Logo">
      #
      # @example CDN Mode
      #
      #   <%= image 'logo.png' %>
      #
      #   # <img src="https://assets.bookshelf.org/assets/logo-28a6b886de2372ee3922fcaf3f78f2d8.png" alt="Logo">
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
        _asset_url(source) { _relative_url(source) }
      end

      def asset_url(source)
        _asset_url(source) { _absolute_url(source) }
      end

      private

      def _safe_tags(*sources)
        ::Lotus::Utils::Escape::SafeString.new(
          sources.map do |source|
            yield source
          end.join(NEW_LINE_SEPARATOR)
        )
      end

      def _asset_url(source)
        _push_promise(
          _absolute_url?(source) ?
            source : yield
        )
      end

      def _typed_asset_path(source, ext)
        source = "#{ source }#{ ext }" unless source.match(/#{ Regexp.escape(ext) }\z/)
        asset_path(source)
      end

      def _absolute_url?(source)
        URI.regexp.match(source)
      end

      def _relative_url(source)
        self.class.assets_configuration.asset_path(source)
      end

      def _absolute_url(source)
        self.class.assets_configuration.asset_url(source)
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
