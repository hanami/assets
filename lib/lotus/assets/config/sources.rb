require 'lotus/utils/load_paths'

module Lotus
  module Assets
    # Configuration settings
    #
    # @since x.x.x
    # @api private
    module Config
      # Source directories for a specific application
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Assets.duplicate
      # @see http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/LoadPaths
      #
      # TODO The perf of this class is poor, consider to improve it.
      class Sources < Utils::LoadPaths
        # @since x.x.x
        # @api private
        attr_writer :root

        # @since x.x.x
        # @api private
        def initialize(root)
          super()
          @root = root
        end

        # @since x.x.x
        # @api private
        def map
          Array.new.tap do |result|
            each do |source|
              result << yield(source)
            end
          end
        end

        # @since x.x.x
        # @api private
        def find(filename)
          result = files(filename).first
          result = Pathname.new(result) unless result.nil?
          result
        end

        # @since x.x.x
        # @api private
        def files(name = nil)
          result = []

          Dir.glob(map {|source| "#{ source }#{ ::File::SEPARATOR }**#{ ::File::SEPARATOR }#{ name }*"}).each do |file|
            next if ::File.directory?(file) || ::File.basename(file).match(/\A\_/)
            result << file
          end

          result
        end

        # @since x.x.x
        # @api private
        def to_a
          map {|s| s }
        end

        private
        # @since x.x.x
        # @api private
        def realpath(path)
          @root.join(path).realpath
        end
      end
    end
  end
end
