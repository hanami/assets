require 'lotus/utils/load_paths'

module Lotus
  module Assets
    module Config
      # Source directories for a specific asset type (eg. only javascripts)
      # @api private
      #
      # TODO The perf of this class is poor, consider to improve it.
      class Sources < Utils::LoadPaths
        attr_writer :root

        def initialize(root)
          super()
          @root = root
        end

        def map
          Array.new.tap do |result|
            each do |source|
              result << yield(source)
            end
          end
        end

        def find(filename)
          matcher = %r{/(?!\.)#{filename}}

          files.each do |file|
            return file if matcher.match(file.to_s)
          end

          nil
        end

        private
        def files
          map(&:children).flatten
        end

        def realpath(path)
          @root.join(path).realpath
        end
      end
    end
  end
end
