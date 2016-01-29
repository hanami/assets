require 'hanami/utils/load_paths'

module Hanami
  module Assets
    # Configuration settings
    #
    # @since 0.1.0
    # @api private
    module Config
      # Source directories for a specific application
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets.duplicate
      # @see http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/LoadPaths
      #
      # TODO The perf of this class is poor, consider to improve it.
      class Sources < Utils::LoadPaths
        # @since 0.1.0
        # @api private
        attr_writer :root

        # @since 0.1.0
        # @api private
        def initialize(root)
          super()
          @root = root
        end

        # @since 0.1.0
        # @api private
        def map
          Array.new.tap do |result|
            each do |source|
              result << yield(source)
            end
          end
        end

        # @since 0.1.0
        # @api private
        def find(filename)
          result = files(filename).first
          result = Pathname.new(result) unless result.nil?
          result
        end

        # @since 0.1.0
        # @api private
        def files(name = nil)
          result = []

          Dir.glob(map {|source| "#{ source }#{ ::File::SEPARATOR }**#{ ::File::SEPARATOR }#{ name }*"}).each do |file|
            next if ::File.directory?(file) || ::File.basename(file).match(/\A\_/)
            result << file
          end

          result
        end

        private
        # @since 0.1.0
        # @api private
        def realpath(path)
          @root.join(path).realpath
        end
      end
    end
  end
end
