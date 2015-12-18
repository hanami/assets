require 'pathname'
require 'json'
require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/utils/path_prefix'
require 'lotus/utils/basic_object'
require 'lotus/assets/config/manifest'
require 'lotus/assets/config/sources'

module Lotus
  module Assets
    # Framework configuration
    #
    # @since x.x.x
    class Configuration
      # @since x.x.x
      # @api private
      DEFAULT_SCHEME           = 'http'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_HOST             = 'localhost'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_PORT             = '2300'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_PUBLIC_DIRECTORY = 'public'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_MANIFEST         = 'assets.json'.freeze

      # @since x.x.x
      # @api private
      DEFAULT_PREFIX           = '/assets'.freeze

      # @since x.x.x
      # @api private
      URL_SEPARATOR            = '/'.freeze

      # @since x.x.x
      # @api private
      HTTP_SCHEME              = 'http'.freeze

      # @since x.x.x
      # @api private
      HTTP_PORT                = '80'.freeze

      # @since x.x.x
      # @api private
      HTTPS_SCHEME             = 'https'.freeze

      # @since x.x.x
      # @api private
      HTTPS_PORT               = '443'.freeze

      # Return a copy of the configuration of the framework instance associated
      # with the given class.
      #
      # When multiple instances of Lotus::Assets are used in the same
      # application, we want to make sure that a controller or an action will
      # receive the expected configuration.
      #
      # @param base [Class, Module] a controller or an action
      #
      # @return [Lotus::Assets::Configuration] the configuration associated
      #   to the given class.
      #
      # @since x.x.x
      # @api private
      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::Assets")
        framework.configuration
      end

      # @since x.x.x
      # @api private
      attr_reader :digest_manifest

      # Return a new instance
      #
      # @return [Lotus::Assets::Configuration] a new instance
      #
      # @since x.x.x
      # @api private
      def initialize
        reset!
      end

      # Compile mode
      #
      # Determine if compile assets from sources to destination.
      # Usually this is turned off in production mode.
      #
      # @since x.x.x
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
      # @since x.x.x
      def digest(value = nil)
        if value.nil?
          @digest
        else
          @digest = value
        end
      end

      # CDN mode
      #
      # Determine if the helpers should always generate absolute URL.
      # This is useful in production mode.
      #
      # @since x.x.x
      def cdn(value = nil)
        if value.nil?
          @cdn
        else
          @cdn = !!value
        end
      end

      # URL scheme for the application
      #
      # This is used to generate absolute URL from helpers.
      #
      # @since x.x.x
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
      # @since x.x.x
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
      # @since x.x.x
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
      # @since x.x.x
      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = Utils::PathPrefix.new(value)
        end
      end

      # Sources root
      #
      # @since x.x.x
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
      # @since x.x.x
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
      # @since x.x.x
      # @api private
      def destination_directory
        @destination_directory ||= public_directory.join(*prefix.split(URL_SEPARATOR))
      end

      # Manifest path from public directory
      #
      # @since x.x.x
      def manifest(value = nil)
        if value.nil?
          @manifest
        else
          @manifest = value.to_s
        end
      end

      # Absolute manifest path
      #
      # @since x.x.x
      # @api private
      def manifest_path
        public_directory.join(manifest)
      end

      # Application's assets sources
      #
      # @since x.x.x
      # @api private
      def sources
        @sources ||= Lotus::Assets::Config::Sources.new(root)
      end

      # Application's assets
      #
      # @since x.x.x
      # @api private
      def files
        sources.files
      end

      # Find a file from sources
      #
      # @since x.x.x
      # @api private
      def find(file)
        @sources.find(file)
      end

      # Relative URL
      #
      # @since x.x.x
      # @api private
      def asset_path(source)
        cdn ?
          asset_url(source) :
          compile_path(source)
      end

      # Absolute URL
      #
      # @since x.x.x
      # @api private
      def asset_url(source)
        "#{ @base_url }#{ compile_path(source) }"
      end

      # @since x.x.x
      # @api private
      def duplicate
        Configuration.new.tap do |c|
          c.root             = root
          c.scheme           = scheme
          c.host             = host
          c.port             = port
          c.prefix           = prefix
          c.cdn              = cdn
          c.compile          = compile
          c.public_directory = public_directory
          c.manifest         = manifest
          c.sources          = sources.dup
        end
      end

      # @since x.x.x
      # @api private
      def reset!
        @scheme                = DEFAULT_SCHEME
        @host                  = DEFAULT_HOST
        @port                  = DEFAULT_PORT

        @prefix                = Utils::PathPrefix.new(DEFAULT_PREFIX)
        @cdn                   = false
        @compile               = false
        @destination_directory = nil
        @digest_manifest       = Config::NullDigestManifest.new(self)

        root             Dir.pwd
        public_directory root.join(DEFAULT_PUBLIC_DIRECTORY)
        manifest         DEFAULT_MANIFEST
      end

      # Load the configuration
      #
      # This MUST be executed before to accept the first HTTP request
      #
      # @since x.x.x
      def load!
        if digest && manifest_path.exist?
          @digest_manifest = Config::DigestManifest.new(
            JSON.load(manifest_path.read),
            manifest_path
          )
        end

        @base_url = URI::Generic.build(scheme: scheme, host: host, port: url_port).to_s
      end

      protected

      # @since x.x.x
      # @api private
      attr_writer :cdn

      # @since x.x.x
      # @api private
      attr_writer :compile

      # @since x.x.x
      # @api private
      attr_writer :scheme

      # @since x.x.x
      # @api private
      attr_writer :host

      # @since x.x.x
      # @api private
      attr_writer :port

      # @since x.x.x
      # @api private
      attr_writer :prefix

      # @since x.x.x
      # @api private
      attr_writer :root

      # @since x.x.x
      # @api private
      attr_writer :public_directory

      # @since x.x.x
      # @api private
      attr_writer :manifest

      # @since x.x.x
      # @api private
      attr_writer :sources

      private

      # @since x.x.x
      # @api private
      def compile_path(source)
        result = prefix.join(source)
        result = digest_manifest.resolve(result) if digest
        result.to_s
      end

      # @since x.x.x
      # @api private
      def url_port
        ( (scheme == HTTP_SCHEME  && port == HTTP_PORT  ) ||
          (scheme == HTTPS_SCHEME && port == HTTPS_PORT ) ) ? nil : port.to_i
      end
    end
  end
end
