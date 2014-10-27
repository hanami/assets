require 'uri'
require 'lotus/assets/config/asset'

module Lotus
  module Assets
    class Configuration
      PATH_SEPARATOR = '/'.freeze
      ASSETS         = ->{{
        javascript: Config::Asset.new {
          tag    %(<script src="%s" type="text/javascript"></script>)
          source %(/%s.js)
        },
        stylesheet: Config::Asset.new {
          tag    %(<link href="%s" type="text/css" rel="stylesheet">)
          source %(/%s.css)
        }
      }}.freeze

      def initialize
        reset!
      end

      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = value
        end
      end

      def define(type, &blk)
        # FIXME unify the semantic of access to @definitions
        if @definitions[type]
          @definitions[type].define(&blk)
        else
          @definitions[type] = Config::Asset.new(&blk)
        end
      end

      def asset_path(type, source)
        definition = asset(type)

        source = if absolute_url?(source)
          source
        else
          definition.source % [ prefix, definition.path, source ].compact.join(PATH_SEPARATOR)
        end

        definition.tag % source
      end

      def asset(type)
        @definitions.fetch(type)
      end

      def absolute_url?(source)
        URI.regexp.match(source)
      end

      def reset!
        @definitions = ASSETS.call
        @prefix      = nil
      end
    end
  end
end
