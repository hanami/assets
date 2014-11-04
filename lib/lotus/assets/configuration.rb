require 'pathname'
require 'lotus/utils/path_prefix'
require 'lotus/assets/config/asset_type'

module Lotus
  module Assets
    class UnknownAssetType < ::StandardError
      def initialize(type)
        super("Unknown asset type: `#{ type }'")
      end
    end

    class Configuration
      DEFAULT_DESTINATION = 'public'.freeze
      ASSET_TYPES = ->(root){Hash.new{|h,k| h[k] = Config::AssetType.new(root) }.merge!({
        javascript: Config::AssetType.new(root) {
          tag %(<script src="%s" type="text/javascript"></script>)
          ext %(.js)
        },
        stylesheet: Config::AssetType.new(root) {
          tag %(<link href="%s" type="text/css" rel="stylesheet">)
          ext %(.css)
        }
      })}.freeze

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
          @prefix = Utils::PathPrefix.new(value)
        end
      end

      def define(type, &blk)
        @types[type.to_sym].define(&blk)
      end

      def root(value = nil)
        if value.nil?
          @root
        else
          @root = Pathname.new(value).realpath
          @types.each {|_,t| t.root = @root }
        end
      end

      def destination(value = nil)
        if value.nil?
          @destination
        else
          @destination = Pathname.new(value)
        end
      end

      def reset!
        @types   = ASSET_TYPES.call(root)
        @prefix  = Utils::PathPrefix.new
        @compile = false

        root        Dir.pwd
        destination root.join(DEFAULT_DESTINATION)
      end

      # @api private
      def asset(type)
        @types.fetch(type) { raise UnknownAssetType.new(type) }
      end
    end
  end
end
