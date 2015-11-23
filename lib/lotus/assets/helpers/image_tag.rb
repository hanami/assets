module Lotus
  module Assets
    module Helpers
      class ImageTag
        def self.render(configuration, source, alt: '')
          definition = configuration.asset(:image)
          alt        = create_alt(source)
          path       = Lotus::Utils::String.new(source).titleize
          # path       = File.basename(source, File.extname(source)).titleize

          definition.tag % [path, alt]
        end

        private

        def self.create_alt(source)
          alt = source.dup
          alt.tr!('_', ' ')
          alt.tr!('-', ' ')
          alt.capitalize
        end
      end
    end
  end
end
