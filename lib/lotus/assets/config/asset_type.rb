require 'lotus/utils/path_prefix'
require 'lotus/assets/config/sources'

module Lotus
  module Assets
    module Config
      class AssetType
        DEFAULT_PREFIX = '/assets'.freeze

        # @api private
        attr_reader :sources

        # @api private
        def initialize(root, &blk)
          @sources = Sources.new(root)
          prefix     DEFAULT_PREFIX

          define(&blk) if block_given?
        end

        # @api private
        def root=(value)
          @sources.root = value
        end

        # @api private
        def find(name)
          @sources.find(name)
        end

        # @api private
        def define(&blk)
          instance_eval(&blk)
        end

        def prefix(value = nil)
          if value.nil?
            @prefix
          else
            @prefix = Utils::PathPrefix.new(value)
          end
        end

        def tag(value = nil)
          if value.nil?
            @tag
          else
            @tag = value
          end
        end

        def ext(value = nil)
          if value.nil?
            @ext
          else
            @ext = value
          end
        end

        # @api private
        def relative_path(filename)
          prefix.relative_join(filename)
        end
      end
    end
  end
end
