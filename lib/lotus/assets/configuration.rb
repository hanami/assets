require 'pathname'
require 'lotus/utils/string'
require 'lotus/utils/class'
require 'lotus/utils/path_prefix'
require 'lotus/assets/config/asset_types'
require 'lotus/assets/config/sources'

module Lotus
  module Assets
    class Configuration
      DEFAULT_DESTINATION = 'public'.freeze
      DISCARDED_PREFIX    = '/'.freeze

      def self.for(base)
        # TODO this implementation is similar to Lotus::Controller::Configuration consider to extract it into Lotus::Utils
        namespace = Utils::String.new(base).namespace
        framework = Utils::Class.load_from_pattern!("(#{namespace}|Lotus)::Assets")
        framework.configuration
      end

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

      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = Utils::PathPrefix.new(value) unless DISCARDED_PREFIX == value
        end
      end

      def define(type, &blk)
        @types.define(type, &blk)
      end

      def root(value = nil)
        if value.nil?
          @root
        else
          @root = Pathname.new(value).realpath
          sources.root = @root
        end
      end

      def destination(value = nil)
        if value.nil?
          @destination
        else
          @destination = Pathname.new(value)
        end
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

      def duplicate
        Configuration.new.tap do |c|
          c.root        = root
          c.prefix      = prefix
          c.compile     = compile
          c.types       = types.dup
          c.destination = destination
          c.sources     = sources.dup
        end
      end

      def reset!
        @prefix  = Utils::PathPrefix.new
        @types   = Config::AssetTypes.new(@prefix)
        @compile = false

        root        Dir.pwd
        destination root.join(DEFAULT_DESTINATION)
      end

      # @api private
      def asset(type)
        @types.asset(type)
      end

      protected
      attr_writer :compile
      attr_writer :prefix
      attr_writer :root
      attr_writer :destination
      attr_writer :sources
      attr_accessor :types
    end
  end
end
