require 'lotus/utils/load_paths'
require 'lotus/utils/path_prefix'

module Lotus
  module Assets
    module Config
      class AssetType
        DEFAULT_PREFIX = '/assets'.freeze

        attr_reader :load_paths

        def initialize(&blk)
          @load_paths = Utils::LoadPaths.new
          prefix        DEFAULT_PREFIX

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
        def find(source)
          source = "#{ source }.*"

          # FIXME this is really unefficient
          @load_paths.each do |load_path|
            path = Pathname.glob(load_path.join(source)).first
            return path.to_s unless path.nil?
          end

          nil
        end

        # @api private
        def relative_path(source)
          prefix.relative_join(source + ext)
        end
      end
    end
  end
end
