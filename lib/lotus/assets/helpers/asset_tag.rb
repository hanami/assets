require 'uri'
require 'lotus/assets/compiler'

module Lotus
  module Assets
    module Helpers
      class AssetTag
        def self.render(configuration, type, source)
          definition = configuration.asset(type)
          path       = source

          unless absolute_url?(source)
            path = configuration.prefix.join(definition.prefix, source) +
              definition.ext

            Assets::Compiler.compile(configuration, type, source)
          end

          definition.tag % path
        end

        private
        def self.absolute_url?(source)
          URI.regexp.match(source)
        end
      end
    end
  end
end
