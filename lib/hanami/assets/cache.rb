require 'pathname'

module Hanami
  module Assets
    # Store assets references when compile mode is on.
    #
    # This is especially useful in development mode, where we want to compile
    # only the assets that were changed from last browser refresh.
    #
    # @since 0.1.0
    # @api private
    class Cache
      # File cache entry
      #
      # @since 0.3.0
      # @api private
      class File
        # @since 0.3.0
        # @api private
        def initialize(file, mtime: nil, dependencies: nil)
          @file  = file.is_a?(String) ? Pathname.new(file) : file
          @mtime = mtime || @file.mtime.utc.to_i

          @dependencies = (dependencies || []).map { |d| self.class.new(d) }
        end

        # @since 0.3.0
        # @api private
        def modified?(other)
          file = other.is_a?(self.class) ? other : self.class.new(other)

          if dependencies?
            modified_dependencies?(file) ||
              mtime <= file.mtime
          else
            mtime < file.mtime
          end
        end

        protected

        # @since 0.3.0
        # @api private
        attr_reader :mtime

        # @since 0.3.0
        # @api private
        attr_reader :dependencies

        # @since 0.3.0
        # @api private
        def modified_dependencies?(other)
          dependencies.all? { |dep| dep.mtime > other.mtime }
        end

        # @since 0.3.0
        # @api private
        def dependencies?
          dependencies.any?
        end
      end

      # Return a new instance
      #
      # @return [Hanami::Assets::Cache] a new instance
      def initialize
        @data  = Hash.new { |h, k| h[k] = File.new(k, mtime: 0) }
        @mutex = Mutex.new
      end

      # Check if the given file was modified
      #
      # @param file [String,Pathname] the file path
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.3.0
      # @api private
      def modified?(file)
        @mutex.synchronize do
          @data[file.to_s].modified?(file)
        end
      end

      # Store the given file reference
      #
      # @param file [String,Pathname] the file path
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since 0.1.0
      # @api private
      def store(file, dependencies = nil)
        @mutex.synchronize do
          @data[file.to_s] = File.new(file, dependencies: dependencies)
        end
      end
    end
  end
end
