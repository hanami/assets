require 'lotus/utils/load_paths'

module Lotus
  module Assets
    # Configuration settings
    #
    # @since x.x.x
    # @api private
    module Config
      # Global asset sources across all the duplicated <tt>Lotus::Assets</tt>
      # instances.
      #
      # @since x.x.x
      # @api private
      #
      # @see Lotus::Assets.duplicate
      # @see http://www.rubydoc.info/gems/lotus-utils/Lotus/Utils/LoadPaths
      class GlobalSources < Utils::LoadPaths
        # @since x.x.x
        # @api private
        def push(*paths)
          super

          sync_configuration
          sync_duplicated_frameworks
        end

        # @since x.x.x
        # @api private
        alias_method :<<, :push

        private

        # @since x.x.x
        # @api private
        def sync_configuration
          Lotus::Assets.configuration.sources << @paths
        end

        # @since x.x.x
        # @api private
        def sync_duplicated_frameworks
          Lotus::Assets.duplicates.each do |duplicate|
            duplicate.configuration.sources << @paths
          end
        end
      end
    end
  end
end
