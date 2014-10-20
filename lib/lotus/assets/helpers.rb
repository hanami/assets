require 'tilt'

module Lotus
  module Assets
    class FolderNotFoundException < StandardError
    end

    class NoFilesFoundException < StandardError
    end

    module Helpers
      def stylesheet(file_name = 'application')
        base_path = "#{Assets.configuration.assets_path}/#{Assets.configuration.stylesheet_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.css"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        raise NoFilesFoundException if files.empty?

        file_with_prefix = files[0]

        template = Tilt.new(file_with_prefix)

        if Assets.configuration.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          "<link rel='stylesheet' href='#{Assets.configuration.path_prefix}/#{Assets.configuration.stylesheet_path}/#{file_name}.css' media='all' />"
        else
          return template.render
        end
      end

      def javascript(file_name = 'application')
        base_path = "#{Assets.configuration.assets_path}/#{Assets.configuration.javascript_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.js"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        raise NoFilesFoundException if files.empty?

        file_with_prefix = files[0]

        template = Tilt.new(file_with_prefix)

        if Assets.configuration.to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          "<script src='#{Assets.configuration.path_prefix}/#{Assets.configuration.javascript_path}/#{file_name}.js'></script>"
        else
          return template.render
        end
      end
    end
  end
end
