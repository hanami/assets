module Lotus
  module Assets
    module Helpers
      class ImageTag
        def self.render(configuration, source, html_options = {})
          definition = configuration.asset(:image)
          path       = definition.url(configuration, source)
          alt        = html_options[:alt] || Lotus::Utils::String.new(File.basename(source, File.extname(source))).titleize

          definition.tag % [path, alt]
        end
      end
    end
  end
end
