require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/less'

module Lotus
  module Assets
    module AssetsHelpers
      def self.included(base)
        namespace_array = base.configuration.namespace.inspect.split('::')
        base_namespace = namespace_array[0].tr('"', '')

        # TODO: find a better way to access the current Lotus::Config::Assets object
        Assets.path = Kernel.const_get(base_namespace)::Application.configuration.assets.to_s

        base.extend(ClassMethods)
      end

      def stylesheet_include_tag
        # TODO: File should be passed in as parameter eg.: <%= stylesheet_include_tag 'application' %>
        file   = 'application'
        base_path = "#{Assets.path}/#{Assets.stylesheet_path}"

        # TODO: Implement caching system (maybe via mtime timestamp?)
        unless File.exist?("#{base_path}/#{file}.css")
          main_template = Tilt.new("#{base_path}/#{file}.#{Assets.css_engine}")

          main_file = File.new("#{base_path}/#{file}.css", 'w')
          main_file.puts main_template.render
          main_file.close
        end

        # TODO: How to get proper base path? eg.: for lotus application mounted under /admin etc..
        "<link rel='stylesheet' href='/admin/stylesheets/#{file}.css' media='all' />"
      end

      def javascript_include_tag
        # TODO: File should be passed in as parameter eg.: <%= stylesheet_include_tag 'application' %>
        file   = 'application'
        base_path = "#{Assets.path}/#{Assets.javascript_path}"

        # TODO: Implement caching system (maybe via mtime timestamp?)
        unless File.exist?("#{base_path}/#{file}.js")
          main_template = Tilt.new("#{base_path}/#{file}.#{Assets.js_engine}")

          main_file = File.new("#{base_path}/#{file}.js", 'w')
          main_file.puts main_template.render
          main_file.close
        end

        # TODO: How to get proper base path? eg.: for lotus application mounted under /admin etc..
        "<script src='/admin/javascripts/#{file}.js'></script>"
      end

      # This module will extend the Lotus::View where you included Lotus::Assets::AssetsHelpers
      # This means all methods defined under Lotus::Assets::AssetsHelpers::ClassMethods are available
      # as class methods in the base class where Lotus::Assets::AssetsHelpers is included.
      module ClassMethods
        def css_engine(engine = nil)
          if engine
            Assets.css_engine = engine
          else
            Assets.css_engine
          end
        end

        def js_engine(engine = nil)
          if engine
            Assets.js_engine = engine
          else
            Assets.js_engine
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
      end
    end
  end
end
