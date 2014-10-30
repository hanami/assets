require 'lotus/utils/path_prefix'
require 'lotus/assets/config/sources'

module Lotus
  module Assets
    module Config
      class AssetType
        DEFAULT_PREFIX = '/assets'.freeze

        attr_reader :sources

        def initialize(&blk)
          @sources = Sources.new
          prefix     DEFAULT_PREFIX

          define(&blk) if block_given?
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
