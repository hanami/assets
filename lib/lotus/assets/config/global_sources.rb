require 'lotus/utils/load_paths'
require 'thread'

module Lotus
  module Assets
    module Config
      class GlobalSources < Utils::LoadPaths
        def initialize(*paths)
          @mutex = Mutex.new
          synchronize { super }
        end

        def push(*paths)
          synchronize do
            super

            sync_configuration
            sync_duplicated_frameworks
          end
        end

        alias_method :<<, :push

        private

        def synchronize(&blk)
          @mutex.synchronize(&blk)
        end

        def sync_configuration
          Lotus::Assets.configuration.sources << @paths
        end

        def sync_duplicated_frameworks
          Lotus::Assets.duplicates.each do |duplicate|
            duplicate.configuration.sources << @paths
          end
        end
      end
    end
  end
end
