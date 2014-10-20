require 'tilt'

module Lotus
  module Assets
    module AssetsHelpers
      def stylesheet(file_name = 'application')
        base_path = "#{Assets.path}/#{Assets.stylesheet_path}"

        compiled_file_path = "#{base_path}/#{file_name}.css"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        file_with_prefix = files[0]

        template = Tilt.new(file_with_prefix)

        if Assets.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          "<link rel='stylesheet' href='#{Assets.path_prefix}/#{Assets.stylesheet_path}/#{file_name}.css' media='all' />"
        else
          return template.render
        end
      end

      def javascript(file_name = 'application')
        base_path = "#{Assets.path}/#{Assets.javascript_path}"

        compiled_file_path = "#{base_path}/#{file_name}.js"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        file_with_prefix = files[0]

        template = Tilt.new(file_with_prefix)

        if Assets.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          "<script src='#{Assets.path_prefix}/#{Assets.javascript_path}/#{file_name}.js'></script>"
        else
          return template.render
        end
      end
    end
  end
end
