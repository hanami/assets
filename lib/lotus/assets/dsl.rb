module Lotus
  module Assets
    module Dsl
      def assets_path(path = nil)
        Assets.configuration.assets_path(path)
      end

      def stylesheet_path(path = nil)
        Assets.configuration.stylesheet_path(path)
      end

      def javascript_path(path = nil)
        Assets.configuration.javascript_path(path)
      end

      def to_file(boolean = nil)
        Assets.configuration.to_file(boolean)
      end

      def path_prefix(path = nil)
        Assets.configuration.path_prefix(path)
      end
    end
  end
end
