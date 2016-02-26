require 'pathname'
require 'json'
require 'hanami/utils/string'
require 'hanami/utils/class'
require 'hanami/utils/path_prefix'
require 'hanami/utils/basic_object'
require 'hanami/assets/config/manifest'
require 'hanami/assets/config/sources'

module Hanami
  module Assets
    # Framework configuration
    #
    # @since 0.1.0
    class Configuration
      # @since 0.1.0
      # @api private
      DEFAULT_SCHEME           = 'http'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_HOST             = 'localhost'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_PORT             = '2300'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_PUBLIC_DIRECTORY = 'public'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_MANIFEST         = 'assets.json'.freeze

      # @since 0.1.0
      # @api private
      DEFAULT_PREFIX           = '/assets'.freeze

      # @since 0.1.0
      # @api private
      URL_SEPARATOR            = '/'.freeze

      # @since 0.1.0
      # @api private
      HTTP_SCHEME              = 'http'.freeze

      # @since 0.1.0
      # @api private
      HTTP_PORT                = '80'.freeze

      # @since 0.1.0
      # @api private
      HTTPS_SCHEME             = 'https'.freeze

      # @since 0.1.0
      # @api private
      HTTPS_PORT               = '443'.freeze

      # @since 0.3.0-add-options-to-javascript-helper
      # @api private
      DEFAULT_SRI_ALGORITHM    = 'sha256'.freeze

      # Return a copy of the configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Hanami::Assets are used in the same
      # application, we want to make sure that a controller or an action will
      # receive the expected configuration.
      #
      # @param base [Class, Module] a controller or an action
      #
      # @return [Hanami::Assets::Configuration] the configuration associated
      #   to the given class.
      #
      # @since 0.1.0
      # @api private
      def self.for(base)
        # TODO this implementation is similar to Hanami::Controller::Configuration consider to extract it into Hanami::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Hanami)::Assets")
        framework.configuration
      end

      # @since 0.1.0
      # @api private
      attr_reader :digest_manifest

      # Return a new instance
      #
      # @return [Hanami::Assets::Configuration] a new instance
      #
      # @since 0.1.0
      # @api private
      def initialize
        reset!
      end

      # Compile mode
      #
      # Determine if compile assets from sources to destination.
      # Usually this is turned off in production mode.
      #
      # @since 0.1.0
      def compile(value = nil)
        if value.nil?
          @compile
        else
          @compile = value
        end
      end

      # Digest mode
      #
      # Determine if the helpers should generate the digest path for an asset.
      # Usually this is turned on in production mode.
      #
      # @since 0.1.0
      def digest(value = nil)
        if value.nil?
          @digest
        else
          @digest = value
        end
      end

      # Subresource integrity mode
      #
      # Determine if the helpers should generate the integrity attribute for an
      # asset. Usually this is turned on in production mode.
      #
      # @since 0.3.0-add-options-to-javascript-helper
      def sri(value = nil)
        if value.nil?
          @sri
        else
          @sri = value
        end
      end

      # CDN mode
      #
      # Determine if the helpers should always generate absolute URL.
      # This is useful in production mode.
      #
      # @since 0.1.0
      def cdn(value = nil)
        if value.nil?
          @cdn
        else
          @cdn = !!value
        end
      end

      # JavaScript compressor
      #
      # Determine which compressor to use for JavaScript files during deploy.
      #
      # By default it's <tt>nil</tt>, that means it doesn't compress JavaScripts at deploy time.
      #
      # It accepts a <tt>Symbol</tt> or an object that respond to <tt>#compress(file)</tt>.
      #
      # The following symbols are accepted:
      #
      #   * <tt>:builtin</tt> - Ruby based implementation of jsmin. It doesn't require any external gem.
      #   * <tt>:yui</tt> - YUI Compressor, it depends on <tt>yui-compressor</tt> gem and it requires Java 1.4+
      #   * <tt>:uglifier</tt> - UglifyJS, it depends on <tt>uglifier</tt> gem and it requires Node.js
      #   * <tt>:closure</tt> - Google Closure Compiler, it depends on <tt>closure-compiler</tt> gem and it requires Java
      #
      # @param value [Symbol,#compress] the compressor
      #
      # @since 0.1.0
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      #
      # @see http://lisperator.net/uglifyjs
      # @see https://rubygems.org/gems/uglifier
      #
      # @see https://developers.google.com/closure/compiler
      # @see https://rubygems.org/gems/closure-compiler
      #
      # @example YUI Compressor
      #   require 'hanami/assets'
      #
      #   Hanami::Assets.configure do
      #     # ...
      #     javascript_compressor :yui
      #   end.load!
      #
      # @example Custom Compressor
      #   require 'hanami/assets'
      #
      #   Hanami::Assets.configure do
      #     # ...
      #     javascript_compressor MyCustomJavascriptCompressor.new
      #   end.load!
      def javascript_compressor(value = nil)
        if value.nil?
          @javascript_compressor
        else
          @javascript_compressor = value
        end
      end

      # Stylesheet compressor
      #
      # Determine which compressor to use for Stylesheet files during deploy.
      #
      # By default it's <tt>nil</tt>, that means it doesn't compress Stylesheets at deploy time.
      #
      # It accepts a <tt>Symbol</tt> or an object that respond to <tt>#compress(file)</tt>.
      #
      # The following symbols are accepted:
      #
      #   * <tt>:builtin</tt> - Ruby based compressor. It doesn't require any external gem. It's fast, but not an efficient compressor.
      #   * <tt>:yui</tt> - YUI-Compressor, it depends on <tt>yui-compressor</tt> gem and requires Java 1.4+
      #   * <tt>:sass</tt> - Sass, it depends on <tt>sass</tt> gem
      #
      # @param value [Symbol,#compress] the compressor
      #
      # @since 0.1.0
      #
      # @see http://yui.github.io/yuicompressor
      # @see https://rubygems.org/gems/yui-compressor
      #
      # @see http://sass-lang.com
      # @see https://rubygems.org/gems/sass
      #
      # @example YUI Compressor
      #   require 'hanami/assets'
      #
      #   Hanami::Assets.configure do
      #     # ...
      #     stylesheet_compressor :yui
      #   end.load!
      #
      # @example Custom Compressor
      #   require 'hanami/assets'
      #
      #   Hanami::Assets.configure do
      #     # ...
      #     stylesheet_compressor MyCustomStylesheetCompressor.new
      #   end.load!
      def stylesheet_compressor(value = nil)
        if value.nil?
          @stylesheet_compressor
        else
          @stylesheet_compressor = value
        end
      end

      # URL scheme for the application
      #
      # This is used to generate absolute URL from helpers.
      #
      # @since 0.1.0
      def scheme(value = nil)
        if value.nil?
          @scheme
        else
          @scheme = value
        end
      end

      # URL host for the application
      #
      # This is used to generate absolute URL from helpers.
      #
      # @since 0.1.0
      def host(value = nil)
        if value.nil?
          @host
        else
          @host = value
        end
      end

      # URL port for the application
      #
      # This is used to generate absolute URL from helpers.
      #
      # @since 0.1.0
      def port(value = nil)
        if value.nil?
          @port
        else
          @port = value.to_s
        end
      end

      # URL port for the application
      #
      # This is used to generate absolute or relative URL from helpers.
      #
      # @since 0.1.0
      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = Utils::PathPrefix.new(value)
        end
      end

      # Sources root
      #
      # @since 0.1.0
      def root(value = nil)
        if value.nil?
          @root
        else
          @root = Pathname.new(value).realpath
          sources.root = @root
        end
      end

      # Application public directory
      #
      # @since 0.1.0
      def public_directory(value = nil)
        if value.nil?
          @public_directory
        else
          @public_directory = Pathname.new(::File.expand_path(value))
        end
      end

      # Destination directory
      #
      # It's the combination of <tt>public_directory</tt> and <tt>prefix</tt>.
      #
      # @since 0.1.0
      # @api private
      def destination_directory
        @destination_directory ||= public_directory.join(*prefix.split(URL_SEPARATOR))
      end

      # Manifest path from public directory
      #
      # @since 0.1.0
      def manifest(value = nil)
        if value.nil?
          @manifest
        else
          @manifest = value.to_s
        end
      end

      # Absolute manifest path
      #
      # @since 0.1.0
      # @api private
      def manifest_path
        public_directory.join(manifest)
      end

      # Application's assets sources
      #
      # @since 0.1.0
      # @api private
      def sources
        @sources ||= Hanami::Assets::Config::Sources.new(root)
      end

      # Application's assets
      #
      # @since 0.1.0
      # @api private
      def files
        sources.files
      end

      # Find a file from sources
      #
      # @since 0.1.0
      # @api private
      def find(file)
        @sources.find(file)
      end

      # Relative URL
      #
      # @since 0.1.0
      # @api private
      def asset_path(source)
        cdn ?
          asset_url(source) :
          compile_path(source)
      end

      # Absolute URL
      #
      # @since 0.1.0
      # @api private
      def asset_url(source)
        "#{ @base_url }#{ compile_path(source) }"
      end

      # An array of digest algorithms to use for generating asset subresource
      # integrity (SRI) checks
      #
      # @since 0.3.0-add-options-to-javascript-helper
      def sri_algorithm
        [DEFAULT_SRI_ALGORITHM]
      end

      # Subresource integrity attribute
      # @since 0.3.0-add-options-to-javascript-helper
      # @api private
      def sri_value(source)
        if sri
          result = prefix.join(source)
          result = digest_manifest.resolve(result)
          result.fetch('sri').to_s
        end
      end

      # Load Javascript compressor
      #
      # @return [Hanami::Assets::Compressors::Javascript] a compressor
      #
      # @raise [Hanami::Assets::Compressors::UnknownCompressorError] when the
      #   given name refers to an unknown compressor engine
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Configuration#javascript_compressor
      # @see Hanami::Assets::Compressors::Javascript#for
      def js_compressor
        require 'hanami/assets/compressors/javascript'
        Hanami::Assets::Compressors::Javascript.for(javascript_compressor)
      end

      # Load Stylesheet compressor
      #
      # @return [Hanami::Assets::Compressors::Stylesheet] a compressor
      #
      # @raise [Hanami::Assets::Compressors::UnknownCompressorError] when the
      #   given name refers to an unknown compressor engine
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Configuration#stylesheet_compressor
      # @see Hanami::Assets::Compressors::Stylesheet#for
      def css_compressor
        require 'hanami/assets/compressors/stylesheet'
        Hanami::Assets::Compressors::Stylesheet.for(stylesheet_compressor)
      end

      # @since 0.1.0
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.root                  = root
          c.scheme                = scheme
          c.host                  = host
          c.port                  = port
          c.prefix                = prefix
          c.sri                   = sri
          c.cdn                   = cdn
          c.compile               = compile
          c.public_directory      = public_directory
          c.manifest              = manifest
          c.sources               = sources.dup
          c.javascript_compressor = javascript_compressor
          c.stylesheet_compressor = stylesheet_compressor
        end
      end

      # @since 0.1.0
      # @api private
      def reset!
        @scheme                = DEFAULT_SCHEME
        @host                  = DEFAULT_HOST
        @port                  = DEFAULT_PORT

        @prefix                = Utils::PathPrefix.new(DEFAULT_PREFIX)
        @sri                   = false
        @cdn                   = false
        @compile               = false
        @destination_directory = nil
        @digest_manifest       = Config::NullDigestManifest.new(self)

        @javascript_compressor = nil
        @stylesheet_compressor = nil

        root             Dir.pwd
        public_directory root.join(DEFAULT_PUBLIC_DIRECTORY)
        manifest         DEFAULT_MANIFEST
      end

      # Load the configuration
      #
      # This MUST be executed before to accept the first HTTP request
      #
      # @since 0.1.0
      def load!
        if (digest || sri) && manifest_path.exist?
          @digest_manifest = Config::DigestManifest.new(
            JSON.load(manifest_path.read),
            manifest_path
          )
        end

        @base_url = URI::Generic.build(scheme: scheme, host: host, port: url_port).to_s
      end

      protected

      # @since 0.3.0-add-options-to-javascript-helper
      # @api private
      attr_writer :sri

      # @since 0.1.0
      # @api private
      attr_writer :cdn

      # @since 0.1.0
      # @api private
      attr_writer :compile

      # @since 0.1.0
      # @api private
      attr_writer :scheme

      # @since 0.1.0
      # @api private
      attr_writer :host

      # @since 0.1.0
      # @api private
      attr_writer :port

      # @since 0.1.0
      # @api private
      attr_writer :prefix

      # @since 0.1.0
      # @api private
      attr_writer :root

      # @since 0.1.0
      # @api private
      attr_writer :public_directory

      # @since 0.1.0
      # @api private
      attr_writer :manifest

      # @since 0.1.0
      # @api private
      attr_writer :sources

      # @since 0.1.0
      # @api private
      attr_writer :javascript_compressor

      # @since 0.1.0
      # @api private
      attr_writer :stylesheet_compressor

      private

      # @since 0.1.0
      # @api private
      def compile_path(source)
        result = prefix.join(source)

        if digest
          result = digest_manifest.resolve(result)
          result = result.fetch('target')
        end

        result.to_s
      end

      # @since 0.1.0
      # @api private
      def url_port
        ( (scheme == HTTP_SCHEME  && port == HTTP_PORT  ) ||
          (scheme == HTTPS_SCHEME && port == HTTPS_PORT ) ) ? nil : port.to_i
      end
    end
  end
end
