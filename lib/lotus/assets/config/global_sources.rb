require 'lotus/utils/load_paths'

module Lotus
  module Assets
    module Config
      class GlobalSources < Utils::LoadPaths
        def push(*paths)
          super

          sync_configuration
          sync_duplicated_frameworks
        end

        alias_method :<<, :push

        private

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
