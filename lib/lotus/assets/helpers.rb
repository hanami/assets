module Lotus
  module Assets
    module Helpers
      def javascript(file)
        %(<script src="/#{ _javascript_prefix }/#{ file }.js" type="text/javascript"></script>)
      end

      def stylesheet(file)
        %(<link href="/#{ _stylesheet_prefix }/#{ file }.css" type="text/css" rel="stylesheet">)
      end

      private
      def _javascript_prefix
        'assets'
      end

      def _stylesheet_prefix
        'assets'
      end
    end
  end
end
