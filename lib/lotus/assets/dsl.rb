module Lotus
  module Assets
    # This module will extend the Lotus::View where you included Lotus::Assets::AssetsHelpers
    # This means all methods defined under Lotus::Assets::AssetsHelpers::ClassMethods are available
    # as class methods in the base class where Lotus::Assets::AssetsHelpers is included.
    module Dsl
      def stylesheet_path(path = nil)
        if path
          Assets.stylesheet_path = path
        else
          Assets.stylesheet_path
        end
      end

      def javascript_path(path = nil)
        if path
          Assets.javascript_path = path
        else
          Assets.javascript_path
        end
      end

      def to_file(boolean = nil)
        unless boolean.nil?
          Assets.to_file = boolean
        else
          Assets.to_file
        end
      end

      def path_prefix(path = nil)
        if path
          Assets.path_prefix = path
        else
          Assets.path_prefix
        end
      end
    end
  end
end
