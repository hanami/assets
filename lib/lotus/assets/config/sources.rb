require 'lotus/utils/load_paths'

module Lotus
  module Assets
    module Config
      class Sources < Utils::LoadPaths
        # TODO improve perf
        def map
          Array.new.tap do |result|
            each do |source|
              result << yield(source)
            end
          end
        end
      end
    end
  end
end
