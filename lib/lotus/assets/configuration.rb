module Lotus
  module Assets
    class Configuration
      def clear!
        instance_variables.each do |ivar|
          remove_instance_variable ivar
        end
      end

      def stylesheet_path(path = nil)
        if path
          @stylesheet_path = path
        else
          @stylesheet_path || 'stylesheets'
        end
      end

      def javascript_path(path = nil)
        if path
          @javascript_path = path
        else
          @javascript_path || 'javascripts'
        end
      end

      def to_file(boolean = nil)
        unless boolean.nil?
          @to_file = boolean
        else
          if @to_file.nil?
            true
          else
            @to_file
          end
        end
      end

      def path_prefix(prefix = nil)
        if prefix
          @path_prefix = prefix
        else
          @path_prefix || ''
        end
      end

      def assets_path(path = nil)
        if path
          @assets_path = path
        else
          @assets_path || 'assets'
        end
      end
    end
  end
end
