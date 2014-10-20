module Lotus
  module Assets
    # This module will extend the Lotus::View where you included Lotus::Assets::AssetsHelpers
    # This means all methods defined under Lotus::Assets::AssetsHelpers::ClassMethods are available
    # as class methods in the base class where Lotus::Assets::AssetsHelpers is included.
    module Dsl
      def assets_path(path = nil)
        if path
          Assets.configuration.assets_path = path
        else
          Assets.configuration.assets_path
        end
      end

      def stylesheet_path(path = nil)
        if path
          Assets.configuration.stylesheet_path = path
        else
          Assets.configuration.stylesheet_path
        end
      end

      def javascript_path(path = nil)
        if path
          Assets.configuration.javascript_path = path
        else
          Assets.configuration.javascript_path
        end
      end

      def to_file(boolean = nil)
        unless boolean.nil?
          Assets.configuration.to_file = boolean
        else
          Assets.configuration.to_file
        end
      end

      def path_prefix(path = nil)
        if path
          Assets.configuration.path_prefix = path
        else
          Assets.configuration.path_prefix
        end
      end
    end
  end
end
