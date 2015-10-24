require 'lotus/utils/path_prefix'

module Lotus
  module Assets
    module Config
      class AssetType
        DEFAULT_PREFIX = '/assets'.freeze

        # @api private
        def initialize_copy(original)
          @destination = original.destination.dup
          @prefix      = original.prefix.dup
          @tag         = original.tag.dup
          @ext         = original.ext.dup
        end

        # @api private
        def initialize(destination, &blk)
          @destination = Utils::PathPrefix.new(destination)
          prefix         DEFAULT_PREFIX

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
          @destination.relative_join(filename)
        end

        def url(configuration_prefix, source)
          prefix.join(configuration_prefix, source) +
            ext
        end

        protected
        attr_reader :destination
      end
    end
  end
end
