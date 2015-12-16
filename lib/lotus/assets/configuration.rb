require 'pathname'
require 'json'
require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/utils/path_prefix'
require 'lotus/utils/basic_object'
require 'lotus/assets/config/sources'

module Lotus
  module Assets
    class MissingManifestError < Error
      def initialize(path)
        super("Can't read manifest: #{ path }")
      end
    end

    class Configuration
      class NullDigestManifest < Utils::BasicObject
        def initialize(configuration)
          @configuration = configuration
        end

        def method_missing(*)
          ::Kernel.raise(
            ::Lotus::Assets::MissingManifestError.new(@configuration.manifest_path)
          )
        end
      end

      DEFAULT_SCHEME           = 'http'.freeze
      DEFAULT_HOST             = 'localhost'.freeze
      DEFAULT_PORT             = '2300'.freeze
      DEFAULT_PUBLIC_DIRECTORY = 'public'.freeze
      DEFAULT_MANIFEST         = 'assets.json'.freeze
      DEFAULT_PREFIX           = '/assets'.freeze
      URL_SEPARATOR            = '/'.freeze

      HTTP_SCHEME              = 'http'.freeze
      HTTP_PORT                = '80'.freeze

      HTTPS_SCHEME             = 'https'.freeze
      HTTPS_PORT               = '443'.freeze

      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::Assets")
        framework.configuration
      end

      attr_reader :digest_manifest

      def initialize
        reset!
      end

      def compile(value = nil)
        if value.nil?
          @compile
        else
          @compile = value
        end
      end

      def digest(value = nil)
        if value.nil?
          @digest
        else
          @digest = value
        end
      end

      def cdn(value = nil)
        if value.nil?
          @cdn
        else
          @cdn = !!value
        end
      end

      def scheme(value = nil)
        if value.nil?
          @scheme
        else
          @scheme = value
        end
      end

      def host(value = nil)
        if value.nil?
          @host
        else
          @host = value
        end
      end

      def port(value = nil)
        if value.nil?
          @port
        else
          @port = value.to_s
        end
      end

      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = Utils::PathPrefix.new(value)
        end
      end

      def root(value = nil)
        if value.nil?
          @root
        else
          @root = Pathname.new(value).realpath
          sources.root = @root
        end
      end

      def public_directory(value = nil)
        if value.nil?
          @public_directory
        else
          @public_directory = Pathname.new(::File.expand_path(value))
        end
      end

      def destination_directory
        @destination_directory ||= public_directory.join(*prefix.split(URL_SEPARATOR))
      end

      def manifest(value = nil)
        if value.nil?
          @manifest
        else
          @manifest = value.to_s
        end
      end

      # @api private
      def manifest_path
        public_directory.join(manifest)
      end

      def sources
        @sources ||= Lotus::Assets::Config::Sources.new(root)
      end

      def files
        sources.files
      end

      # @api private
      def find(file)
        @sources.find(file)
      end

      # @api private
      def asset_path(source)
        cdn ?
          asset_url(source) :
          compile_path(source)
      end

      # @api private
      def asset_url(source)
        "#{ @base_url }#{ compile_path(source) }"
      end

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

      def reset!
        @scheme                = DEFAULT_SCHEME
        @host                  = DEFAULT_HOST
        @port                  = DEFAULT_PORT

        @prefix                = Utils::PathPrefix.new(DEFAULT_PREFIX)
        @cdn                   = false
        @compile               = false
        @destination_directory = nil
        @digest_manifest       = NullDigestManifest.new(self)

        root             Dir.pwd
        public_directory root.join(DEFAULT_PUBLIC_DIRECTORY)
        manifest         DEFAULT_MANIFEST
      end

      def load!
        if digest && manifest_path.exist?
          @digest_manifest = JSON.load(manifest_path.read)
        end

        @base_url = URI::Generic.build(scheme: scheme, host: host, port: url_port).to_s
      end

      protected
      attr_writer :cdn
      attr_writer :compile
      attr_writer :scheme
      attr_writer :host
      attr_writer :port
      attr_writer :prefix
      attr_writer :root
      attr_writer :public_directory
      attr_writer :manifest
      attr_writer :sources

      private

      # @api private
      def compile_path(source)
        result = prefix.join(source)
        result = digest_manifest.fetch(result.to_s) if digest
        result.to_s
      end

      # @api private
      def url_port
        ( (scheme == HTTP_SCHEME  && port == HTTP_PORT  ) ||
          (scheme == HTTPS_SCHEME && port == HTTPS_PORT ) ) ? nil : port.to_i
      end
    end
  end
end
