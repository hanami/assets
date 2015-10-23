require 'uri'
require 'set'
require 'thread'
require 'lotus/assets/compiler'

module Lotus
  module Assets
    module Helpers
      class AssetTag
        def self.render(configuration, type, source)
          definition = configuration.asset(type)
          path       = source

          unless absolute_url?(source)
            path = definition.url(configuration.prefix, source)
            Assets::Compiler.compile(configuration, type, source)
          end

          cache(path)
          definition.tag % path
        end

        private
        def self.absolute_url?(source)
          URI.regexp.match(source)
        end

        def self.cache(path)
          Mutex.new.synchronize do
            Thread.current[:__lotus_assets] ||= Set.new
            Thread.current[:__lotus_assets].add(path.to_s)
          end
        end
      end
    end
  end
end
