require 'tilt/sass'
require 'tilt/coffee'

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
        file   = 'application'
        base_path = "#{Assets.path}/stylesheets"

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
        file   = 'application'
        base_path = "#{Assets.path}/javascripts"

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
      end
    end
  end
end
