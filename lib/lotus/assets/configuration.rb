module Lotus
  module Assets
    class Configuration
      attr_writer :assets_path
      attr_writer :stylesheet_path, :javascript_path
      attr_writer :to_file, :path_prefix

      def clear!
        instance_variables.each do |ivar|
          remove_instance_variable ivar
        end
      end

      def stylesheet_path
        @stylesheet_path || 'stylesheets'
      end

      def javascript_path
        @javascript_path || 'javascripts'
      end

      def to_file
        if @to_file.nil?
          true
        else
          @to_file
        end
      end

      def path_prefix
        @path_prefix || ''
      end

      def assets_path
        @assets_path || 'assets'
      end
    end
  end
end
