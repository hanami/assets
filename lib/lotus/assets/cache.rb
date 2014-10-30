require 'thread'

module Lotus
  module Assets
    class Cache
      def initialize
        @data  = Hash.new{|h,k| h[k] = 0 }
        @mutex = Mutex.new
      end

      def fresh?(file)
        @mutex.synchronize do
          @data[file.to_s] < mtime(file)
        end
      end

      def store(file)
        @mutex.synchronize do
          @data[file.to_s] = mtime(file)
        end
      end

      private
      def mtime(file)
        file.mtime.utc.to_i
      end
    end
  end
end
