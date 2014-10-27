require 'uri'

module Lotus
  module Assets
    module Helpers
      JAVASCRIPT_TAG_TEMPLATE    = %(<script src="%s" type="text/javascript"></script>).freeze
      JAVASCRIPT_SOURCE_TEMPLATE = %(/%s.js).freeze

      STYLESHEET_TAG_TEMPLATE    = %(<link href="%s" type="text/css" rel="stylesheet">).freeze
      STYLESHEET_SOURCE_TEMPLATE = %(/%s.css).freeze

      def javascript(*sources)
        sources.map do |source|
          source = JAVASCRIPT_SOURCE_TEMPLATE % javascript_path(source) unless absolute_url?(source)
          JAVASCRIPT_TAG_TEMPLATE % source
        end.join("\n")
      end

      def stylesheet(*sources)
        sources.map do |source|
          source = STYLESHEET_SOURCE_TEMPLATE % stylesheet_path(source) unless absolute_url?(source)
          STYLESHEET_TAG_TEMPLATE % source
        end.join("\n")
      end

      private
      def javascript_path(source)
        [ assets_prefix, javascript_prefix, source ].compact.join('/')
      end

      def stylesheet_path(source)
        [ assets_prefix, stylesheet_prefix, source ].compact.join('/')
      end

      def javascript_prefix
        'assets'
      end

      def stylesheet_prefix
        'assets'
      end

      def assets_prefix
        nil
      end

      def absolute_url?(source)
        URI.regexp.match(source)
      end
    end
  end
end
