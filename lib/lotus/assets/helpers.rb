require 'tilt'

module Lotus
  module Assets
    FolderNotFoundException = Class.new(StandardError)
    NoFilesFoundException   = Class.new(StandardError)

    module Helpers
      include Dsl

      def stylesheet(file_name = 'application')
        # TODO: REFACTOR
        base_path = "#{assets_path}/#{stylesheet_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.css"

        files_in_dir = Dir["#{base_path}/#{file_name}.*"]
        raise NoFilesFoundException if files_in_dir.empty?

        file_with_prefix = files_in_dir[0]

        if file_with_prefix === compiled_file_path
          return "<link rel='stylesheet' href='#{path_prefix}/#{stylesheet_path}/#{file_name}.css' media='all' />"
        end

        template = Tilt.new(file_with_prefix)

        if to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          # Currently user has to set a custom path_prefix via Lotus::Assets.configure
          "<link rel='stylesheet' href='#{path_prefix}/#{stylesheet_path}/#{file_name}.css' media='all' />"
        else
          return template.render
        end
      end

      def javascript(file_name = 'application')
        # TODO: REFACTOR
        base_path = "#{assets_path}/#{javascript_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.js"

        files_in_dir = Dir["#{base_path}/#{file_name}.*"]
        raise NoFilesFoundException if files_in_dir.empty?

        file_with_prefix = files_in_dir[0]

        if file_with_prefix == compiled_file_path
          return "<script src='#{path_prefix}/#{javascript_path}/#{file_name}.js'></script>"
        end

        template = Tilt.new(file_with_prefix)

        if to_file
          # TODO: Implement caching system (maybe via mtime timestamp?)
          unless File.exist?(compiled_file_path)
            file = File.new(compiled_file_path, 'w')
            file.puts template.render
            file.close
          end

          # TODO: How to get proper path_prefix? eg.: for lotus application mounted under /admin etc..
          # Currently user has to set a custom path_prefix via Lotus::Assets.configure
          "<script src='#{path_prefix}/#{javascript_path}/#{file_name}.js'></script>"
        else
          return template.render
        end
      end
    end
  end
end
