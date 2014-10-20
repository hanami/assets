require 'tilt'

module Lotus
  module Assets
    class FolderNotFoundException < StandardError
    end

    class NoFilesFoundException < StandardError
    end

    module Helpers
      include Dsl

      def self.included(base)
        ##
        # Extremely nasty but it works for now
        if base.respond_to?(:configuration)
          namespace = base.configuration.namespace

          if namespace.is_a?(String)
            base_namespace = namespace.split("::")[0]
            assets_config = Kernel.const_get(base_namespace)::Application.configuration.assets

            Assets.configuration.assets_path(assets_config)
          end
        end
      end

      def stylesheet(file_name = 'application')
        base_path = "#{assets_path}/#{stylesheet_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.css"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        raise NoFilesFoundException if files.empty?

        file_with_prefix = files[0]

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
        base_path = "#{assets_path}/#{javascript_path}"
        raise FolderNotFoundException unless Dir.exist?(base_path)

        compiled_file_path = "#{base_path}/#{file_name}.js"
        files_in_dir = Dir["#{base_path}/#{file_name}.*"]

        files = files_in_dir - [compiled_file_path]
        raise NoFilesFoundException if files.empty?

        file_with_prefix = files[0]

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
