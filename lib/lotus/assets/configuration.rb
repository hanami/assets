module Lotus
  module Assets
    class Configuration
      def prefix(value = nil)
        if value.nil?
          @prefix
        else
          @prefix = value
        end
      end

      def javascripts_path(value = nil)
        if value.nil?
          @javascripts_path
        else
          @javascripts_path = value
        end
      end

      def stylesheets_path(value = nil)
        if value.nil?
          @stylesheets_path
        else
          @stylesheets_path = value
        end
      end

      def reset!
        @prefix           = nil
        @javascripts_path = 'assets'
        @stylesheets_path = 'assets'
      end
    end
  end
end
