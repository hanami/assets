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
        def initialize_copy(original)
          @sources = original.sources.dup
          @destination = original.destination.dup
          @prefix  = original.prefix.dup
          @tag     = original.tag.dup
          @ext     = original.ext.dup
        end

        # @api private
        def initialize(root, destination, &blk)
          @sources     = Sources.new(root)
          @destination = Utils::PathPrefix.new(destination)
          prefix         DEFAULT_PREFIX

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
          @destination.relative_join(filename)
        end

        def url(configuration_prefix, source)
          configuration_prefix.join(prefix, source) +
            ext
        end

        protected
        attr_reader :destination
      end
    end
  end
end
