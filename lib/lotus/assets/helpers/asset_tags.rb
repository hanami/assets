require 'uri'

module Lotus
  module Assets
    module Helpers
      class AssetTags
        LINE_SEPARATOR = "\n".freeze
        PATH_SEPARATOR = "/".freeze
        CONFIGURATION  = {
           javascript: {
             tag:    %(<script src="%s" type="text/javascript"></script>),
             source: %(/%s.js)
           },
           stylesheet: {
             tag:    %(<link href="%s" type="text/css" rel="stylesheet">),
             source: %(/%s.css)
           }
        }.freeze

        def self.render(type, *sources)
          config = CONFIGURATION.fetch(type)

          sources.map do |source|
            unless absolute_url?(source)
              source = config[:source] % asset_path(type, source)
            end

            config[:tag] % source
          end.join(LINE_SEPARATOR)
        end

        private
        def self.configuration
          Lotus::Assets.configuration
        end

        def self.asset_path(type, source)
          [ assets_prefix, __send__("#{ type }_prefix"), source ].compact.join(PATH_SEPARATOR)
        end

        def self.javascript_prefix
          configuration.javascripts_path
        end

        def self.stylesheet_prefix
          configuration.stylesheets_path
        end

        def self.assets_prefix
          configuration.prefix
        end

        def self.absolute_url?(source)
          URI.regexp.match(source)
        end
      end
    end
  end
end
