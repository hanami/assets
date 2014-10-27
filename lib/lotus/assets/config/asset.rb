module Lotus
  module Assets
    module Config
      class Asset
        DEFAULT_PATH = 'assets'.freeze

        def initialize(&blk)
          @path = DEFAULT_PATH
          define(&blk)
        end

        def define(&blk)
          instance_eval(&blk)
        end

        def path(value = nil)
          if value.nil?
            @path
          else
            @path = value
          end
        end

        def tag(value = nil)
          if value.nil?
            @tag
          else
            @tag = value
          end
        end

        def source(value = nil)
          if value.nil?
            @source
          else
            @source = value
          end
        end
      end
    end
  end
end
