module Lotus
  module Assets
    module Helpers
      def javascript(*files)
        files.map do |file|
          %(<script src="/#{ javascript_path(file) }.js" type="text/javascript"></script>)
        end.join("\n")
      end

      def stylesheet(*files)
        files.map do |file|
          %(<link href="/#{ stylesheet_path(file) }.css" type="text/css" rel="stylesheet">)
        end.join("\n")
      end

      private
      def javascript_path(file)
        [ assets_prefix, javascript_prefix, file ].compact.join('/')
      end

      def stylesheet_path(file)
        [ assets_prefix, stylesheet_prefix, file ].compact.join('/')
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
    end
  end
end
