# frozen_string_literal: true

require "uri"
require "hanami/view"

module Hanami
  module Assets
    # HTML assets helpers
    #
    # Inject these helpers in a view
    #
    # @since 0.1.0
    #
    # @see http://www.rubydoc.info/gems/hanami-helpers/Hanami/Helpers/HtmlHelper
    class Helpers
      # @since 0.1.0
      # @api private
      NEW_LINE_SEPARATOR = "\n"

      # @since 0.1.0
      # @api private
      WILDCARD_EXT = ".*"

      # @since 0.1.0
      # @api private
      JAVASCRIPT_EXT = ".js"

      # @since 0.1.0
      # @api private
      STYLESHEET_EXT = ".css"

      # @since 0.1.0
      # @api private
      JAVASCRIPT_MIME_TYPE = "text/javascript"

      # @since 0.1.0
      # @api private
      STYLESHEET_MIME_TYPE = "text/css"

      # @since 0.1.0
      # @api private
      FAVICON_MIME_TYPE = "image/x-icon"

      # @since 0.1.0
      # @api private
      STYLESHEET_REL = "stylesheet"

      # @since 0.1.0
      # @api private
      FAVICON_REL = "shortcut icon"

      # @since 0.1.0
      # @api private
      DEFAULT_FAVICON = "favicon.ico"

      # @since 0.3.0
      # @api private
      CROSSORIGIN_ANONYMOUS = "anonymous"

      # @since 0.3.0
      # @api private
      ABSOLUTE_URL_MATCHER = URI::DEFAULT_PARSER.make_regexp

      # @since 1.1.0
      # @api private
      QUERY_STRING_MATCHER = /\?/

      include Hanami::View::Helpers::TagHelper

      attr_reader :source
      private :source

      attr_reader :configuration
      private :configuration

      attr_reader :inflector
      private :inflector

      # Initialize a new instance
      #
      # @param configuration [Hanami::Assets::Configuration] the assets configuration
      # @inflector [Dry::Inflector] the inflector
      #
      # @return [Hanami::Assets::Helpers] a new instance
      #
      # @since 2.1.0
      # @api private
      def initialize(source:, configuration:, inflector:)
        super()
        # Force the lazy loading of the tag builder, so we can freeze this instance
        # (see Hanami::View::Helpers::TagHelper)
        tag_builder

        @source = source
        @configuration = configuration
        @inflector = inflector

        freeze
      end

      # Generate `script` tag for given source(s)
      #
      # It accepts one or more strings representing the name of the asset, if it
      # comes from the application or third party gems. It also accepts strings
      # representing absolute URLs in case of public CDN (eg. jQuery CDN).
      #
      # If the "fingerprint mode" is on, `src` is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the `src` is an absolute URL of the
      # application CDN.
      #
      # If the "subresource integrity mode" is on, `integriy` is the
      # name of the algorithm, then a hyphen, then the hash value of the file.
      # If more than one algorithm is used, they"ll be separated by a space.
      #
      # It makes the script(s) eligible for HTTP/2 Push Promise/Early Hints.
      # You can opt-out with inline option: `push: false`.
      #
      # @param sources [Array<String>] one or more assets by name or absolute URL
      # @param push [TrueClass, FalseClass] HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the javascript file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Single Asset
      #
      #   <%= assets.js "application" %>
      #
      #   # <script src="/assets/application.js" type="text/javascript"></script>
      #
      # @example Multiple Assets
      #
      #   <%= assets.js "application", "dashboard" %>
      #
      #   # <script src="/assets/application.js" type="text/javascript"></script>
      #   # <script src="/assets/dashboard.js" type="text/javascript"></script>
      #
      # @example Asynchronous Execution
      #
      #   <%= assets.js "application", async: true %>
      #
      #   # <script src="/assets/application.js" type="text/javascript" async="async"></script>
      #
      # @example Subresource Integrity
      #
      #   <%= assets.js "application" %>
      #
      #   # <script src="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #   #         type="text/javascript" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Subresource Integrity for 3rd Party Scripts
      #
      #   <%= assets.js "https://example.com/assets/example.js", integrity: "sha384-oqVu...Y8wC" %>
      #
      #   # <script src="https://example.com/assets/example.js" type="text/javascript"
      #   #         integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Deferred Execution
      #
      #   <%= assets.js "application", defer: true %>
      #
      #   # <script src="/assets/application.js" type="text/javascript" defer="defer"></script>
      #
      # @example Absolute URL
      #
      #   <%= assets.js "https://code.jquery.com/jquery-2.1.4.min.js" %>
      #
      #   # <script src="https://code.jquery.com/jquery-2.1.4.min.js" type="text/javascript"></script>
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.js "application" %>
      #
      #   # <script src="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js" type="text/javascript"></script>
      #
      # @example CDN Mode
      #
      #   <%= assets.js "application" %>
      #
      #   # <script src="https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #   #         type="text/javascript"></script>
      #
      # @example Disable Push Promise/Early Hints
      #
      #   <%= assets.js "application", push: false %>
      #   <%= assets.js "http://cdn.example.test/jquery.js", "dashboard", push: false %>
      def javascript(*source_paths, push: true, **options)
        options = options.reject { |k, _| k.to_sym == :src }

        _safe_tags(*source_paths) do |source|
          attributes = {
            src: _typed_path(source, JAVASCRIPT_EXT, push: push, as: :script),
            type: JAVASCRIPT_MIME_TYPE
          }
          attributes.merge!(options)

          if _subresource_integrity? || attributes.include?(:integrity)
            attributes[:integrity] ||= _subresource_integrity_value(source, JAVASCRIPT_EXT)
            attributes[:crossorigin] ||= CROSSORIGIN_ANONYMOUS
          end

          tag.script(**attributes).to_s
        end
      end

      # @api public
      # @since 2.1.0
      alias_method :js, :javascript

      # Generate `link` tag for given source(s)
      #
      # It accepts one or more strings representing the name of the asset, if it
      # comes from the application or third party gems. It also accepts strings
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # If the "fingerprint mode" is on, `href` is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the `href` is an absolute URL of the
      # application CDN.
      #
      # If the "subresource integrity mode" is on, `integriy` is the
      # name of the algorithm, then a hyphen, then the hashed value of the file.
      # If more than one algorithm is used, they"ll be separated by a space.
      #
      # It makes the script(s) eligible for HTTP/2 Push Promise/Early Hints.
      # You can opt-out with inline option: `push: false`.
      #
      # @param sources [Array<String>] one or more assets by name or absolute URL
      # @param push [TrueClass, FalseClass] HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the stylesheet file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Single Asset
      #
      #   <%= assets.css "application" %>
      #
      #   # <link href="/assets/application.css" type="text/css" rel="stylesheet">
      #
      # @example Multiple Assets
      #
      #   <%= assets.css "application", "dashboard" %>
      #
      #   # <link href="/assets/application.css" type="text/css" rel="stylesheet">
      #   # <link href="/assets/dashboard.css" type="text/css" rel="stylesheet">
      #
      # @example Subresource Integrity
      #
      #   <%= assets.css "application" %>
      #
      #   # <link href="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css"
      #   #       type="text/css" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Subresource Integrity for 3rd Party Assets
      #
      #   <%= assets.css "https://example.com/assets/example.css", integrity: "sha384-oqVu...Y8wC" %>
      #
      #   # <link href="https://example.com/assets/example.css"
      #   #       type="text/css" rel="stylesheet" integrity="sha384-oqVu...Y8wC" crossorigin="anonymous"></script>
      #
      # @example Absolute URL
      #
      #   <%= assets.css "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" %>
      #
      #   # <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css"
      #   #       type="text/css" rel="stylesheet">
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.css "application" %>
      #
      #   # <link href="/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css" type="text/css" rel="stylesheet">
      #
      # @example CDN Mode
      #
      #   <%= assets.css "application" %>
      #
      #   # <link href="https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.css"
      #   #       type="text/css" rel="stylesheet">
      #
      # @example Disable Push Promise/Early Hints
      #
      #   <%= assets.css "application", push: false %>
      #   <%= assets.css "http://cdn.example.test/bootstrap.css", "dashboard", push: false %>
      def stylesheet(*source_paths, push: true, **options)
        options = options.reject { |k, _| k.to_sym == :href }

        _safe_tags(*source_paths) do |source_path|
          attributes = {
            href: _typed_path(source_path, STYLESHEET_EXT, push: push, as: :style),
            type: STYLESHEET_MIME_TYPE,
            rel: STYLESHEET_REL
          }
          attributes.merge!(options)

          if _subresource_integrity? || attributes.include?(:integrity)
            attributes[:integrity] ||= _subresource_integrity_value(source_path, STYLESHEET_EXT)
            attributes[:crossorigin] ||= CROSSORIGIN_ANONYMOUS
          end

          tag.link(**attributes).to_s
        end
      end

      # @api public
      # @since 2.1.0
      alias_method :css, :stylesheet

      # Generate `img` tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # `alt` Attribute is auto generated from `src`.
      # You can specify a different value, by passing the `:src` option.
      #
      # If the "fingerprint mode" is on, `src` is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the `src` is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      # @param options [Hash] HTML 5 attributes
      # @option options [TrueClass, FalseClass] :push HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the image file is missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Basic Usage
      #
      #   <%= assets.img "logo.png" %>
      #
      #   # <img src="/assets/logo.png" alt="Logo">
      #
      # @example Custom alt Attribute
      #
      #   <%= assets.img "logo.png", alt: "Application Logo" %>
      #
      #   # <img src="/assets/logo.png" alt="Application Logo">
      #
      # @example Custom HTML Attributes
      #
      #   <%= assets.img "logo.png", id: "logo", class: "image" %>
      #
      #   # <img src="/assets/logo.png" alt="Logo" id="logo" class="image">
      #
      # @example Absolute URL
      #
      #   <%= assets.img "https://example-cdn.com/images/logo.png" %>
      #
      #   # <img src="https://example-cdn.com/images/logo.png" alt="Logo">
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.img "logo.png" %>
      #
      #   # <img src="/assets/logo-28a6b886de2372ee3922fcaf3f78f2d8.png" alt="Logo">
      #
      # @example CDN Mode
      #
      #   <%= assets.img "logo.png" %>
      #
      #   # <img src="https://assets.bookshelf.org/assets/logo-28a6b886de2372ee3922fcaf3f78f2d8.png" alt="Logo">
      #
      # @example Enable Push Promise/Early Hints
      #
      #   <%= assets.img "logo.png", push: true %>
      def image(source, options = {})
        options = options.reject { |k, _| k.to_sym == :src }
        attributes = {
          src: self[source, push: options.delete(:push) || false, as: :image],
          alt: inflector.humanize(::File.basename(source, WILDCARD_EXT))
        }
        attributes.merge!(options)

        tag.img(**attributes)
      end

      # @api public
      # @since 2.1.0
      alias_method :img, :image

      # Generate `link` tag application favicon.
      #
      # If no argument is given, it assumes `favico.ico` from the application.
      #
      # It accepts one string representing the name of the asset.
      #
      # If the "fingerprint mode" is on, `href` is the fingerprinted version
      # of the relative URL.
      #
      # If the "CDN mode" is on, the `href` is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name
      # @param options [Hash] HTML 5 attributes
      # @option options [TrueClass, FalseClass] :push HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the favicon is file missing
      # from the manifest
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Basic Usage
      #
      #   <%= assets.favicon %>
      #
      #   # <link href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Custom Path
      #
      #   <%= assets.favicon "fav.ico" %>
      #
      #   # <link href="/assets/fav.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Custom HTML Attributes
      #
      #   <%= assets.favicon "favicon.ico", id: "fav" %>
      #
      #   # <link id: "fav" href="/assets/favicon.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.favicon %>
      #
      #   # <link href="/assets/favicon-28a6b886de2372ee3922fcaf3f78f2d8.ico" rel="shortcut icon" type="image/x-icon">
      #
      # @example CDN Mode
      #
      #   <%= assets.favicon %>
      #
      #   # <link href="https://assets.bookshelf.org/assets/favicon-28a6b886de2372ee3922fcaf3f78f2d8.ico"
      #           rel="shortcut icon" type="image/x-icon">
      #
      # @example Enable Push Promise/Early Hints
      #
      #   <%= assets.favicon "favicon.ico", push: true %>
      def favicon(source = DEFAULT_FAVICON, options = {})
        options = options.reject { |k, _| k.to_sym == :href }

        attributes = {
          href: self[source, push: options.delete(:push) || false, as: :image],
          rel: FAVICON_REL,
          type: FAVICON_MIME_TYPE
        }
        attributes.merge!(options)

        tag.link(**attributes)
      end

      # Generate `video` tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # Alternatively, it accepts a block that allows to specify one or more
      # sources via the `source` tag.
      #
      # If the "fingerprint mode" is on, `src` is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the `src` is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      # @param options [Hash] HTML 5 attributes
      # @option options [TrueClass, FalseClass] :push HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the video file is missing
      # from the manifest
      #
      # @raise [ArgumentError] if source isn"t specified both as argument or
      #   tag inside the given block
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Basic Usage
      #
      #   <%= assets.video "movie.mp4" %>
      #
      #   # <video src="/assets/movie.mp4"></video>
      #
      # @example Absolute URL
      #
      #   <%= assets.video "https://example-cdn.com/assets/movie.mp4" %>
      #
      #   # <video src="https://example-cdn.com/assets/movie.mp4"></video>
      #
      # @example Custom HTML Attributes
      #
      #   <%= assets.video("movie.mp4", autoplay: true, controls: true) %>
      #
      #   # <video src="/assets/movie.mp4" autoplay="autoplay" controls="controls"></video>
      #
      # @example Fallback Content
      #
      #   <%=
      #     assets.video("movie.mp4") do
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
      #     assets.video("movie.mp4") do
      #       tag.track(kind: "captions", src: assets.path("movie.en.vtt"),
      #             srclang: "en", label: "English")
      #     end
      #   %>
      #
      #   # <video src="/assets/movie.mp4">
      #   #   <track kind="captions" src="/assets/movie.en.vtt" srclang="en" label="English">
      #   # </video>
      #
      # @example Without Any Argument
      #
      #   <%= assets.video %>
      #
      #   # ArgumentError
      #
      # @example Without src And Without Block
      #
      #   <%= assets.video(content: true) %>
      #
      #   # ArgumentError
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.video "movie.mp4" %>
      #
      #   # <video src="/assets/movie-28a6b886de2372ee3922fcaf3f78f2d8.mp4"></video>
      #
      # @example CDN Mode
      #
      #   <%= assets.video "movie.mp4" %>
      #
      #   # <video src="https://assets.bookshelf.org/assets/movie-28a6b886de2372ee3922fcaf3f78f2d8.mp4"></video>
      def video(source = nil, options = {}, &blk)
        options = _source_options(source, options, as: :video, &blk)
        tag.video(**options, &blk)
      end

      # Generate `audio` tag for given source
      #
      # It accepts one string representing the name of the asset, if it comes
      # from the application or third party gems. It also accepts string
      # representing absolute URLs in case of public CDN (eg. Bootstrap CDN).
      #
      # Alternatively, it accepts a block that allows to specify one or more
      # sources via the `source` tag.
      #
      # If the "fingerprint mode" is on, `src` is the fingerprinted
      # version of the relative URL.
      #
      # If the "CDN mode" is on, the `src` is an absolute URL of the
      # application CDN.
      #
      # @param source [String] asset name or absolute URL
      # @param options [Hash] HTML 5 attributes
      # @option options [TrueClass, FalseClass] :push HTTP/2 Push Promise/Early Hints flag
      #
      # @return [Hanami::View::HTML::SafeString] the markup
      #
      # @raise [Hanami::Assets::MissingManifestAssetError] if `fingerprint` or
      # `subresource_integrity` modes are on and the audio file is missing
      # from the manifest
      #
      # @raise [ArgumentError] if source isn"t specified both as argument or
      #   tag inside the given block
      #
      # @since 0.1.0
      #
      # @see Hanami::Assets::Helpers#path
      #
      # @example Basic Usage
      #
      #   <%= assets.audio "song.ogg" %>
      #
      #   # <audio src="/assets/song.ogg"></audio>
      #
      # @example Absolute URL
      #
      #   <%= assets.audio "https://example-cdn.com/assets/song.ogg" %>
      #
      #   # <audio src="https://example-cdn.com/assets/song.ogg"></audio>
      #
      # @example Custom HTML Attributes
      #
      #   <%= assets.audio("song.ogg", autoplay: true, controls: true) %>
      #
      #   # <audio src="/assets/song.ogg" autoplay="autoplay" controls="controls"></audio>
      #
      # @example Fallback Content
      #
      #   <%=
      #     assets.audio("song.ogg") do
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
      #     assets.audio("song.ogg") do
      #       tag.track(kind: "captions", src: assets.path("song.pt-BR.vtt"),
      #             srclang: "pt-BR", label: "Portuguese")
      #     end
      #   %>
      #
      #   # <audio src="/assets/song.ogg">
      #   #   <track kind="captions" src="/assets/song.pt-BR.vtt" srclang="pt-BR" label="Portuguese">
      #   # </audio>
      #
      # @example Without Any Argument
      #
      #   <%= assets.audio %>
      #
      #   # ArgumentError
      #
      # @example Without src And Without Block
      #
      #   <%= assets.audio(controls: true) %>
      #
      #   # ArgumentError
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.audio "song.ogg" %>
      #
      #   # <audio src="/assets/song-28a6b886de2372ee3922fcaf3f78f2d8.ogg"></audio>
      #
      # @example CDN Mode
      #
      #   <%= assets.audio "song.ogg" %>
      #
      #   # <audio src="https://assets.bookshelf.org/assets/song-28a6b886de2372ee3922fcaf3f78f2d8.ogg"></audio>
      def audio(source = nil, options = {}, &blk)
        options = _source_options(source, options, as: :audio, &blk)
        tag.audio(**options, &blk)
      end

      # It generates the relative or absolute URL for the given asset.
      # It automatically decides if it has to use the relative or absolute
      # depending on the configuration and current environment.
      #
      # Absolute URLs are returned as they are.
      #
      # It can be the name of the asset, coming from the sources or third party
      # gems.
      #
      # If Fingerprint mode is on, it returns the fingerprinted path of the source
      #
      # If CDN mode is on, it returns the absolute URL of the asset.
      #
      # @param source [String] the asset name
      # @param push [TrueClass, FalseClass, Symbol] HTTP/2 Push Promise/Early Hints flag, or type
      # @param as [Symbol] HTTP/2 Push Promise / Early Hints flag type
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
      #   <%= assets.path "application.js" %>
      #
      #   # "/assets/application.js"
      #
      # @example Alias
      #
      #   <%= assets["application.js"] %>
      #
      #   # "/assets/application.js"
      #
      # @example Absolute URL
      #
      #   <%= assets.path "https://code.jquery.com/jquery-2.1.4.min.js" %>
      #
      #   # "https://code.jquery.com/jquery-2.1.4.min.js"
      #
      # @example Fingerprint Mode
      #
      #   <%= assets.path "application.js" %>
      #
      #   # "/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @example CDN Mode
      #
      #   <%= assets.path "application.js" %>
      #
      #   # "https://assets.bookshelf.org/assets/application-28a6b886de2372ee3922fcaf3f78f2d8.js"
      #
      # @example Enable Push Promise/Early Hints
      #
      #   <%= assets.path "application.js", push: :script %>
      def path(source_path, push: false, as: nil)
        # TODO: Create consistency between this method name and the method we call on the asset
        _path(source_path, push: push, as: as) { source[source_path].url }
      end

      # @api public
      # @since 2.1.0
      alias_method :[], :path

      private

      # @since 0.1.0
      # @api private
      def _safe_tags(*source_paths, &blk)
        ::Hanami::View::HTML::SafeString.new(
          source_paths.map(&blk).join(NEW_LINE_SEPARATOR)
        )
      end

      # @since 2.1.0
      # @api private
      def _path(source, push:, as:)
        url = _absolute_url?(source) ? source : yield

        case push
        when Symbol
          _push_promise(url, as: push)
        when TrueClass
          _push_promise(url, as: as)
        end

        url
      end

      # @since 2.1.0
      # @api private
      def _typed_path(source, ext, push: false, as: nil)
        source = "#{source}#{ext}" if _append_extension?(source, ext)
        self[source, push: push, as: as]
      end

      # @api private
      def _subresource_integrity?
        configuration.subresource_integrity.any?
      end

      # @api private
      def _subresource_integrity_value(source_path, ext)
        source_path = "#{source_path}#{ext}" unless /#{Regexp.escape(ext)}\z/.match?(source_path)
        source[source_path].sri unless _absolute_url?(source_path)
      end

      # @since 0.1.0
      # @api private
      def _absolute_url?(source)
        ABSOLUTE_URL_MATCHER.match(source)
      end

      # @since 1.2.0
      # @api private
      def _crossorigin?(source)
        return false unless _absolute_url?(source)

        configuration.crossorigin?(source)
      end

      # @since 0.1.0
      # @api private
      def _source_options(src, options, as:, &blk)
        options ||= {}

        if src.respond_to?(:to_hash)
          options = src.to_hash
        elsif src
          options[:src] = self[src, push: options.delete(:push) || false, as: as]
        end

        if !options[:src] && !blk
          raise ArgumentError.new("You should provide a source via `src` option or with a `source` HTML tag")
        end

        options
      end

      # @since 0.1.0
      # @api private
      def _push_promise(url, as: nil)
        Thread.current[:__hanami_assets] ||= {}
        Thread.current[:__hanami_assets][url.to_s] = {as: as, crossorigin: _crossorigin?(url)}

        url
      end

      # @since 1.1.0
      # @api private
      def _append_extension?(source, ext)
        source !~ QUERY_STRING_MATCHER && source !~ /#{Regexp.escape(ext)}\z/
      end
    end
  end
end
