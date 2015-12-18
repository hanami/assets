require 'thread'

module Lotus
  module Assets
    # Store assets references when compile mode is on.
    #
    # This is expecially useful in development mode, where we want to compile
    # only the assets that were changed from last browser refresh.
    #
    # @since x.x.x
    # @api private
    class Cache
      # Return a new instance
      #
      # @return [Lotus::Assets::Cache] a new instance
      def initialize
        @data  = Hash.new{|h,k| h[k] = 0 }
        @mutex = Mutex.new
      end

      # Check if the given file is fresh or changed from last check.
      #
      # @param file [String,Pathname] the file path
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since x.x.x
      # @api private
      def fresh?(file)
        @mutex.synchronize do
          @data[file.to_s] < mtime(file)
        end
      end

      # Store the given file reference
      #
      # @param file [String,Pathname] the file path
      #
      # @return [TrueClass,FalseClass] the result of the check
      #
      # @since x.x.x
      # @api private
      def store(file)
        @mutex.synchronize do
          @data[file.to_s] = mtime(file)
        end
      end

      private

      # @since x.x.x
      # @api private
      def mtime(file)
        file.mtime.utc.to_i
      end
    end
  end
end
