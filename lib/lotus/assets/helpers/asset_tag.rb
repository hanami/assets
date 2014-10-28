require 'uri'

module Lotus
  module Assets
    module Helpers
      class AssetTag
        def self.render(configuration, type, source)
          definition = configuration.asset(type)

          unless absolute_url?(source)
            source = definition.source %
              configuration.prefix.join(definition.path, source)
          end

          definition.tag % source
        end

        private
        def self.absolute_url?(source)
          URI.regexp.match(source)
        end
      end
    end
  end
end
