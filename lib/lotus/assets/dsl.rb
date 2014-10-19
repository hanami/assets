module Lotus
  module Assets
    # This module will extend the Lotus::View where you included Lotus::Assets::AssetsHelpers
    # This means all methods defined under Lotus::Assets::AssetsHelpers::ClassMethods are available
    # as class methods in the base class where Lotus::Assets::AssetsHelpers is included.
    module Dsl
      def stylesheet_engine(engine = nil)
        if engine
          Assets.stylesheet_engine = engine
        else
          Assets.stylesheet_engine
        end
      end

      def javascript_engine(engine = nil)
        if engine
          Assets.javascript_engine = engine
        else
          Assets.javascript_engine
        end
      end

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

      # Currently stylesheet_file and javascript_file dsl methods are needed so the User
      # is able to decide which asset file he wants to include.
      # For now only configurable once and other assets file have to be imported in this "main file"
      #
      # This is needed because currently methods called in templates are not allowed to have arguments
      # This for example is not possible yet:
      #   <%= sylesheet_include_tag 'application' %>
      def stylesheet_file(file = nil)
        if file
          Assets.stylesheet_file = file
        else
          Assets.stylesheet_file
        end
      end

      def javascript_file(file = nil)
        if file
          Assets.javascript_file = file
        else
          Assets.javascript_file
        end
      end

      def to_file(boolean = nil)
        unless boolean.nil?
          Assets.to_file = boolean
        else
          Assets.to_file
        end
      end
    end
  end
end
