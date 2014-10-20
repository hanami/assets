require 'lotus/assets/version'
require 'lotus/assets/assets_helpers'
require 'lotus/assets/dsl'

module Lotus
  module Assets
    class << self
      attr_accessor :path

      attr_writer :stylesheet_engine, :stylesheet_path, :stylesheet_file
      attr_writer :javascript_engine, :javascript_path, :javascript_file

      attr_writer :to_file, :path_prefix

      def included(base)
        namespace_array = base.configuration.namespace.inspect.split('::')
        base_namespace = namespace_array[0].tr('"', '')

        # TODO: find a better way to access the current Lotus::Config::Assets object
        self.path = Kernel.const_get(base_namespace)::Application.configuration.assets.to_s

        base.extend(Dsl)
        base.include(AssetsHelpers)
      end

      def clear_configuration!
        instance_variables.each do |ivar|
          remove_instance_variable ivar
        end
      end

      def stylesheet_engine
        @stylesheet_engine || 'scss'
      end

      def javascript_engine
        @javascript_engine || 'coffee'
      end

      def stylesheet_path
        @stylesheet_path || 'stylesheets'
      end

      def javascript_path
        @javascript_path || 'javascripts'
      end

      def stylesheet_file
        @stylesheet_file || 'application'
      end

      def javascript_file
        @javascript_file || 'application'
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
    end
  end
end
