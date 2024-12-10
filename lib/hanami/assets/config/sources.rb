# frozen_string_literal: true

require "hanami/cyg_utils/load_paths"
require "hanami/cyg_utils/file_list"

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
      class Sources < CygUtils::LoadPaths
        # @since 0.3.0
        # @api private
        SKIPPED_FILE_PREFIX = "_"

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
          [].tap do |result|
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

          CygUtils::FileList[map { |source| "#{source}#{::File::SEPARATOR}**#{::File::SEPARATOR}#{name}*" }].each do |file|
            next if ::File.directory?(file) || ::File.basename(file).start_with?(SKIPPED_FILE_PREFIX)

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
