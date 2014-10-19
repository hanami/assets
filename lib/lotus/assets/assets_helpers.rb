require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/less'

module Lotus
  module Assets
    module AssetsHelpers
      def stylesheet_include_tag
        # TODO: File should be passed in as parameter eg.: <%= stylesheet_include_tag 'application' %>
        file   = 'application'
        base_path = "#{Assets.path}/#{Assets.stylesheet_path}"

        # TODO: Implement caching system (maybe via mtime timestamp?)
        unless File.exist?("#{base_path}/#{file}.css")
          main_template = Tilt.new("#{base_path}/#{file}.#{Assets.stylesheet_engine}")

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
          main_template = Tilt.new("#{base_path}/#{file}.#{Assets.javascript_engine}")

          main_file = File.new("#{base_path}/#{file}.js", 'w')
          main_file.puts main_template.render
          main_file.close
        end

        # TODO: How to get proper base path? eg.: for lotus application mounted under /admin etc..
        "<script src='/admin/javascripts/#{file}.js'></script>"
      end
    end
  end
end
