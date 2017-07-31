require 'uri'
require 'set'
require 'thread'
require 'hanami/helpers/html_helper'
require 'hanami/utils/escape'

module Hanami
  module Assets
    # HTML assets helpers
    #
    # Include this helper in a view
    #
    # @since 0.1.0
    #
    # @see http://www.rubydoc.info/gems/hanami-helpers/Hanami/Helpers/HtmlHelper
    module Helpers # rubocop:disable Metrics/ModuleLength
      # @since 0.1.0
      # @api private
      NEW_LINE_SEPARATOR = "\n".freeze

      # @since 0.1.0
      # @api private
      WILDCARD_EXT   = '.*'.freeze

      # @since 0.1.0
      # @api private
      JAVASCRIPT_EXT = '.js'.freeze

      # @since 0.1.0
      # @api private
      STYLESHEET_EXT = '.css'.freeze

      # @since 0.1.0
      # @api private
      JAVASCRIPT_MIME_TYPE = 'text/javascript'.freeze

      # @since 0.1.0
      # @api private
      STYLESHEET_MIME_TYPE = 'text/css'.freeze

      # @since 0.1.0
      # @api private
      FAVICON_MIME_TYPE    = 'image/x-icon'.freeze

      # @since 0.1.0
      # @api private
      STYLESHEET_REL  = 'stylesheet'.freeze

      # @since 0.1.0
      # @api private
      FAVICON_REL     = 'shortcut icon'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_FAVICON = 'favicon.ico'.freeze

      # @since 0.3.0
      # @api private
      CROSSORIGIN_ANONYMOUS = 'anonymous'.freeze

      # @since 0.3.0
      # @api private
      ABSOLUTE_URL_MATCHER = URI::Parser.new.make_regexp

      include Hanami::Helpers::HtmlHelper

      # Inject helpers into the given class
      #
      # @since 0.1.0
      # @api private
      def self.included(base)
        conf = ::Hanami::Assets::Configuration.for(base)
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
      # If the "fingerprint mode" is on, <tt>src</tt> is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # If the "subresource integrity mode" is on, <tt>integriy</tt> is the
      # name of the algorithm, then a hyphen, then the hash value of the file.
      # If more than one algorithm is used, they'll be separated by a space.
      #
      # @param sources [Array<String>] one or more assets by name or absolute URL
      #
      # @return [Hanami::Utils::Escape::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the javascript file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Helpers#asset_path
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
      # @example Asynchronous Execution
      #
      #   <%= javascript 'application', async: true %>
      #
      #   # <script src="/assets/application.js" type="text/javascript" async="async"></script>
      #
      # @example Subresource Integrity
      #
      #   <%= javascript 'application' %>
      #
      #   # <script src="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js" type="text/javascript" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Subresource Integrity for 3rd Party Scripts
      #
      #   <%= javascript 'https://example.com/assets/example.js', integrity: 'sha384-oqVu...Y8wC' %>
      #
      #   # <script src="https://example.com/assets/example.js" type="text/javascript" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Deferred Execution
      #
      #   <%= javascript 'application', defer: true %>
      #
      #   # <script src="/assets/application.js" type="text/javascript" defer="defer"></script>
      #
      # @example Absolute URL
      #
      #   <%= javascript 'https://code.jquery.com/jquery-2.1.4.min.js' %>
      #
      #   # <script src="https://code.jquery.com/jquery-2.1.4.min.js" type="text/javascript"></script>
      #
      # @example Fingerprint Mode
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
      def javascript(*sources, **options)
        _safe_tags(*sources) do |source|
          tag_options = options.dup
          tag_options[:src] ||= _typed_asset_path(source, JAVASCRIPT_EXT)
          tag_options[:type] ||= JAVASCRIPT_MIME_TYPE

          if _subresource_integrity? || tag_options.include?(:integrity)
            tag_options[:integrity] ||= _subresource_integrity_value(source, JAVASCRIPT_EXT)
            tag_options[:crossorigin] ||= CROSSORIGIN_ANONYMOUS
          end

          html.script(**tag_options).to_s
        end
      end

      def ujs
        Dir[
          File.join(Gem::Specification.find_by_name("vanilla-ujs").gem_dir,
          "/lib/assets/javascripts/vanilla-ujs/*")
        ].map { |path| File.read(path) }.join
      end

      # Generate <tt>link</tt> tag for given source(s)
      #
      # It accepts one or more strings representing the name of the asset, if it
      # comes from the application or third party gems. It also accepts strings
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # If the "fingerprint mode" is on, <tt>href</tt> is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>href</tt> is an absolute URL of the
      # application CDN.
      #
      # If the "subresource integrity mode" is on, <tt>integriy</tt> is the
      # name of the algorithm, then a hyphen, then the hashed value of the file.
      # If more than one algorithm is used, they'll be separated by a space.
      # @param sources [Array<String>] one or more assets by name or absolute URL
      #
      # @return [Hanami::Utils::Escape::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the stylesheet file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Configuration#subresource_integrity
      # @see Hanami::Assets::Helpers#asset_path
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
      # @example Subresource Integrity
      #
      #   <%= stylesheet 'application' %>
      #
      #   # <link href="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css" type="text/css" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Subresource Integrity for 3rd Party Assets
      #
      #   <%= stylesheet 'https://example.com/assets/example.css', integrity: 'sha384-oqVu...Y8wC' %>
      #
      #   # <link href="https://example.com/assets/example.css" type="text/css" rel="stylesheet" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Absolute URL
      #
      #   <%= stylesheet 'https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css' %>
      #
      #   # <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" type="text/css" rel="stylesheet">
      #
      # @example Fingerprint Mode
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
      def stylesheet(*sources, **options) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        _safe_tags(*sources) do |source|
          tag_options = options.dup
          tag_options[:href] ||= _typed_asset_path(source, STYLESHEET_EXT)
          tag_options[:type] ||= STYLESHEET_MIME_TYPE
          tag_options[:rel] ||= STYLESHEET_REL

          if _subresource_integrity? || tag_options.include?(:integrity)
            tag_options[:integrity] ||= _subresource_integrity_value(source, STYLESHEET_EXT)
            tag_options[:crossorigin] ||= CROSSORIGIN_ANONYMOUS
          end

          html.link(**tag_options).to_s
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
      # If the "fingerprint mode" is on, <tt>src</tt> is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      #
      # @return [Hanami::Utils::Helpers::HtmlBuilder] the builder
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the image file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Configuration#subresource_integrity
      # @see Hanami::Assets::Helpers#asset_path
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
      # @example Fingerprint Mode
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

      # Generate <tt>link</tt> tag application favicon.
      #
      # If no argument is given, it assumes <tt>favico.ico</tt> from the application.
      #
      # It accepts one string representing the name of the asset.
      #
      # If the "fingerprint mode" is on, <tt>href</tt> is the fingerprinted version
      # of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>href</tt> is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name
      #
      # @return [Hanami::Utils::Helpers::HtmlBuilder] the builder
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the favicon is file missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Helpers#asset_path
      #
      # @example Basic Usage
      #
      #   <%= favicon %>
      #
      #   # <link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Custom Path
      #
      #   <%= favicon 'fav.ico' %>
      #
      #   # <link href="/assets/fav.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Custom HTML Attributes
      #
      #   <%= favicon id: 'fav' %>
      #
      #   # <link id: "fav" href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Fingerprint Mode
      #
      #   <%= favicon %>
      #
      #   # <link href="/assets/favicon-28a6b886de2372ee3922fcaf3f78f2d8.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example CDN Mode
      #
      #   <%= favicon %>
      #
      #   # <link href="https://assets.bookshelf.org/assets/favicon-28a6b886de2372ee3922fcaf3f78f2d8.ico" rel="shortcut icon" type="image/x-icon">
      def favicon(source = DEFAULT_FAVICON, options = {})
        options[:href]   = asset_path(source)
        options[:rel]  ||= FAVICON_REL
        options[:type] ||= FAVICON_MIME_TYPE

        html.link(options)
      end

      # Generate <tt>video</tt> tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # Alternatively, it accepts a block that allows to specify one or more
      # sources via the <tt>source</tt> tag.
      #
      # If the "fingerprint mode" is on, <tt>src</tt> is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      #
      # @return [Hanami::Utils::Helpers::HtmlBuilder] the builder
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the video file is missing
      # from the manifest
      #
      # @raise [ArgumentError] if source isn't specified both as argument or
      #   tag inside the given block
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Helpers#asset_path
      #
      # @example Basic Usage
      #
      #   <%= video 'movie.mp4' %>
      #
      #   # <video src="/assets/movie.mp4"></video>
      #
      # @example Absolute URL
      #
      #   <%= video 'https://example-cdn.com/assets/movie.mp4' %>
      #
      #   # <video src="https://example-cdn.com/assets/movie.mp4"></video>
      #
      # @example Custom HTML Attributes
      #
      #   <%= video('movie.mp4', autoplay: true, controls: true) %>
      #
      #   # <video src="/assets/movie.mp4" autoplay="autoplay" controls="controls"></video>
      #
      # @example Fallback Content
      #
      #   <%=
      #     video('movie.mp4') do
      #       "Your browser does not support the video tag"
      #     end
      #   %>
      #
      #   # <video src="/assets/movie.mp4">
      #   #  Your browser does not support the video tag
      #   # </video>
      #
      # @example Tracks
      #
      #   <%=
      #     video('movie.mp4') do
      #       track(kind: 'captions', src:  asset_path('movie.en.vtt'),
      #             srclang: 'en', label: 'English')
      #     end
      #   %>
      #
      #   # <video src="/assets/movie.mp4">
      #   #   <track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">
      #   # </video>
      #
      # @example Sources
      #
      #   <%=
      #     video do
      #       text "Your browser does not support the video tag"
      #       source(src: asset_path('movie.mp4'), type: 'video/mp4')
      #       source(src: asset_path('movie.ogg'), type: 'video/ogg')
      #     end
      #   %>
      #
      #   # <video>
      #   #   Your browser does not support the video tag
      #   #   <source src="/assets/movie.mp4" type="video/mp4">
      #   #   <source src="/assets/movie.ogg" type="video/ogg">
      #   # </video>
      #
      # @example Without Any Argument
      #
      #   <%= video %>
      #
      #   # ArgumentError
      #
      # @example Without src And Without Block
      #
      #   <%= video(content: true) %>
      #
      #   # ArgumentError
      #
      # @example Fingerprint Mode
      #
      #   <%= video 'movie.mp4' %>
      #
      #   # <video src="/assets/movie-28a6b886de2372ee3922fcaf3f78f2d8.mp4"></video>
      #
      # @example CDN Mode
      #
      #   <%= video 'movie.mp4' %>
      #
      #   # <video src="https://assets.bookshelf.org/assets/movie-28a6b886de2372ee3922fcaf3f78f2d8.mp4"></video>
      def video(source = nil, options = {}, &blk)
        options = _source_options(source, options, &blk)
        html.video(blk, options)
      end

      # Generate <tt>audio</tt> tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # Alternatively, it accepts a block that allows to specify one or more
      # sources via the <tt>source</tt> tag.
      #
      # If the "fingerprint mode" is on, <tt>src</tt> is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the <tt>src</tt> is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      #
      # @return [Hanami::Utils::Helpers::HtmlBuilder] the builder
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the audio file is missing
      # from the manifest
      #
      # @raise [ArgumentError] if source isn't specified both as argument or
      #   tag inside the given block
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Configuration#fingerprint
      # @see Hanami::Assets::Configuration#cdn
      # @see Hanami::Assets::Helpers#asset_path
      #
      # @example Basic Usage
      #
      #   <%= audio 'song.ogg' %>
      #
      #   # <audio src="/assets/song.ogg"></audio>
      #
      # @example Absolute URL
      #
      #   <%= audio 'https://example-cdn.com/assets/song.ogg' %>
      #
      #   # <audio src="https://example-cdn.com/assets/song.ogg"></audio>
      #
      # @example Custom HTML Attributes
      #
      #   <%= audio('song.ogg', autoplay: true, controls: true) %>
      #
      #   # <audio src="/assets/song.ogg" autoplay="autoplay" controls="controls"></audio>
      #
      # @example Fallback Content
      #
      #   <%=
      #     audio('song.ogg') do
      #       "Your browser does not support the audio tag"
      #     end
      #   %>
      #
      #   # <audio src="/assets/song.ogg">
      #   #  Your browser does not support the audio tag
      #   # </audio>
      #
      # @example Tracks
      #
      #   <%=
      #     audio('song.ogg') do
      #       track(kind: 'captions', src:  asset_path('song.pt-BR.vtt'),
      #             srclang: 'pt-BR', label: 'Portuguese')
      #     end
      #   %>
      #
      #   # <audio src="/assets/song.ogg">
      #   #   <track kind="captions" src="/assets/song.pt-BR.vtt" srclang="pt-BR" label="Portuguese">
      #   # </audio>
      #
      # @example Sources
      #
      #   <%=
      #     audio do
      #       text "Your browser does not support the audio tag"
      #       source(src: asset_path('song.ogg'), type: 'audio/ogg')
      #       source(src: asset_path('song.wav'), type: 'auido/wav')
      #     end
      #   %>
      #
      #   # <audio>
      #   #   Your browser does not support the audio tag
      #   #   <source src="/assets/song.ogg" type="audio/ogg">
      #   #   <source src="/assets/song.wav" type="auido/wav">
      #   # </audio>
      #
      # @example Without Any Argument
      #
      #   <%= audio %>
      #
      #   # ArgumentError
      #
      # @example Without src And Without Block
      #
      #   <%= audio(controls: true) %>
      #
      #   # ArgumentError
      #
      # @example Fingerprint Mode
      #
      #   <%= audio 'song.ogg' %>
      #
      #   # <audio src="/assets/song-28a6b886de2372ee3922fcaf3f78f2d8.ogg"></audio>
      #
      # @example CDN Mode
      #
      #   <%= audio 'song.ogg' %>
      #
      #   # <audio src="https://assets.bookshelf.org/assets/song-28a6b886de2372ee3922fcaf3f78f2d8.ogg"></audio>
      def audio(source = nil, options = {}, &blk)
        options = _source_options(source, options, &blk)
        html.audio(blk, options)
      end

      # It generates the relative URL for the given source.
      #
      # It can be the name of the asset, coming from the sources or third party
      # gems.
      #
      # Absolute URLs are returned as they are.
      #
      # If Fingerprint mode is on, it returns the fingerprinted path of the source
      #
      # If CDN mode is on, it returns the absolute URL of the asset.
      #
      # @param source [String] the asset name
      #
      # @return [String] the asset path
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the asset is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @example Basic Usage
      #
      #   <%= asset_path 'application.js' %>
      #
      #   # "/assets/application.js"
      #
      # @example Absolute URL
      #
      #   <%= asset_path 'https://code.jquery.com/jquery-2.1.4.min.js' %>
      #
      #   # "https://code.jquery.com/jquery-2.1.4.min.js"
      #
      # @example Fingerprint Mode
      #
      #   <%= asset_path 'application.js' %>
      #
      #   # "/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @example CDN Mode
      #
      #   <%= asset_path 'application.js' %>
      #
      #   # "https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      def asset_path(source)
        _asset_url(source) { _relative_url(source) }
      end

      # It generates the absolute URL for the given source.
      #
      # It can be the name of the asset, coming from the sources or third party
      # gems.
      #
      # Absolute URLs are returned as they are.
      #
      # If Fingerprint mode is on, it returns the fingerprint URL of the source
      #
      # If CDN mode is on, it returns the absolute URL of the asset.
      #
      # @param source [String] the asset name
      #
      # @return [String] the asset URL
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the asset is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @example Basic Usage
      #
      #   <%= asset_url 'application.js' %>
      #
      #   # "https://bookshelf.org/assets/application.js"
      #
      # @example Absolute URL
      #
      #   <%= asset_url 'https://code.jquery.com/jquery-2.1.4.min.js' %>
      #
      #   # "https://code.jquery.com/jquery-2.1.4.min.js"
      #
      # @example Fingerprint Mode
      #
      #   <%= asset_url 'application.js' %>
      #
      #   # "https://bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @example CDN Mode
      #
      #   <%= asset_url 'application.js' %>
      #
      #   # "https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      def asset_url(source)
        _asset_url(source) { _absolute_url(source) }
      end

      private

      # @since 0.1.0
      # @api private
      def _safe_tags(*sources)
        ::Hanami::Utils::Escape::SafeString.new(
          sources.map do |source|
            yield source
          end.join(NEW_LINE_SEPARATOR)
        )
      end

      # @since 0.1.0
      # @api private
      def _asset_url(source)
        _push_promise(
          _absolute_url?(source) ? # rubocop:disable Style/MultilineTernaryOperator
            source : yield
        )
      end

      # @since 0.1.0
      # @api private
      def _typed_asset_path(source, ext)
        source = "#{source}#{ext}" unless source =~ /#{Regexp.escape(ext)}\z/
        asset_path(source)
      end

      # @api private
      def _subresource_integrity?
        !!self.class.assets_configuration.subresource_integrity # rubocop:disable Style/DoubleNegation
      end

      # @api private
      def _subresource_integrity_value(source, ext)
        source = "#{source}#{ext}" unless source =~ /#{Regexp.escape(ext)}\z/
        self.class.assets_configuration.subresource_integrity_value(source) unless _absolute_url?(source)
      end

      # @since 0.1.0
      # @api private
      def _absolute_url?(source)
        ABSOLUTE_URL_MATCHER.match(source)
      end

      # @since 0.1.0
      # @api private
      def _relative_url(source)
        self.class.assets_configuration.asset_path(source)
      end

      # @since 0.1.0
      # @api private
      def _absolute_url(source)
        self.class.assets_configuration.asset_url(source)
      end

      # @since 0.1.0
      # @api private
      def _source_options(src, options, &_blk)
        options ||= {}

        if src.respond_to?(:to_hash)
          options = src.to_hash
        elsif src
          options[:src] = asset_path(src)
        end

        if !options[:src] && !block_given?
          raise ArgumentError.new('You should provide a source via `src` option or with a `source` HTML tag')
        end

        options
      end

      # @since 0.1.0
      # @api private
      def _push_promise(url)
        Mutex.new.synchronize do
          Thread.current[:__hanami_assets] ||= Set.new
          Thread.current[:__hanami_assets].add(url.to_s)
        end

        url
      end
    end
  end
end
