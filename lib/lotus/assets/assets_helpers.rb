require 'tilt/sass'
require 'tilt/coffee'
require 'tilt/less'

module Lotus
  module Assets
    module AssetsHelpers
      def stylesheet_include_tag
        # TODO: File should be passed in as parameter eg.: <%= stylesheet_include_tag 'application' %>
        file = Assets.stylesheet_file

        base_path = "#{Assets.path}/#{Assets.stylesheet_path}"

        if Assets.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?("#{base_path}/#{file}.css")
            template = Tilt.new("#{base_path}/#{file}.#{Assets.stylesheet_engine}")

            file = File.new("#{base_path}/#{file}.css", 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper base path? eg.: for lotus application mounted under /admin etc..
          "<link rel='stylesheet' href='#{Assets.path_prefix}/stylesheets/#{file}.css' media='all' />"
        else
          template = Tilt.new("#{base_path}/#{file}.#{Assets.stylesheet_engine}")

          return template.render
        end
      end

      def javascript_include_tag
        # TODO: File should be passed in as parameter eg.: <%= javascript_include_tag 'application' %>
        file = Assets.javascript_file

        base_path = "#{Assets.path}/#{Assets.javascript_path}"

        if Assets.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?("#{base_path}/#{file}.js")
            template = Tilt.new("#{base_path}/#{file}.#{Assets.javascript_engine}")

            file = File.new("#{base_path}/#{file}.js", 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper base path? eg.: for lotus application mounted under /admin etc..
          "<script src='#{Assets.path_prefix}/javascripts/#{file}.js'></script>"
        else
          template = Tilt.new("#{base_path}/#{file}.#{Assets.javascript_engine}")

          return template.render
        end
      end
    end
  end
end
