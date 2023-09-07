# frozen_string_literal: true

require "json"

module Hanami
  class Assets
    # Assets manifest
    #
    # @since 2.1.0
    # @api private
    class Manifest
      class Null
        # @since 2.1.0
        # @api private
        SEPARATOR = "/"
        private_constant :SEPARATOR

        # @since 2.1.0
        # @api private
        def initialize(prefix)
          super()
          @prefix = prefix
          freeze
        end

        # @since 2.1.0
        # @api private
        def [](path)
          {"url" => @prefix + SEPARATOR + path}
        end
      end

      # @since 2.1.0
      # @api private
      def initialize(path)
        @path = path
        @manifest = ::JSON.parse(::File.read(path))

        freeze
      end

      # @since 2.1.0
      # @api private
      def call(path)
        @manifest.fetch(path)
      end
    end
  end
end
