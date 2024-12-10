# frozen_string_literal: true

require "hanami/cyg_utils/load_paths"

module Hanami
  module Assets
    # Configuration settings
    #
    # @since 0.1.0
    # @api private
    module Config
      # Global asset sources across all the duplicated <tt>Hanami::Assets</tt>
      # instances.
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets.duplicate
      # @see http://www.rubydoc.info/gems/hanami-utils/Hanami/Utils/LoadPaths
      class GlobalSources < CygUtils::LoadPaths
        # @since 0.1.0
        # @api private
        def push(*paths)
          super

          sync_configuration
          sync_duplicated_frameworks
        end

        # @since 0.1.0
        # @api private
        alias_method :<<, :push

        private

        # @since 0.1.0
        # @api private
        def sync_configuration
          Hanami::Assets.configuration.sources << @paths
        end

        # @since 0.1.0
        # @api private
        def sync_duplicated_frameworks
          Hanami::Assets.duplicates.each do |duplicate|
            duplicate.configuration.sources << @paths
          end
        end
      end
    end
  end
end
