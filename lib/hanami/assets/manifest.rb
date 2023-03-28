# frozen_string_literal: true

require "json"

module Hanami
  module Assets
    # Assets manifest
    #
    # @since 2.0.0
    # @api private
    class Manifest
      class Null
        SEPARATOR = "/"
        private_constant :SEPARATOR

        def initialize(prefix)
          super()
          @prefix = prefix
          freeze
        end

        def call(path)
          @prefix + SEPARATOR + path
        end
      end

      # @since 2.0.0
      # @api private
      def initialize(path)
        @path = path
        @manifest = case path
                    when NilClass
                      Null.new
                    when String, Pathname
                      ::JSON.parse(::File.read(path))
                    end

        freeze
      end

      def call(path)
        @manifest.fetch(path)
      end
    end
  end
end
