# frozen_string_literal: true

module Hanami
  module Assets
    module Compilers
      # Sass/SCSS Compiler
      #
      # @since 0.3.0
      # @api private
      class Sass < Compiler
        # @since 0.3.0
        # @api private
        EXTENSIONS = /\.(sass|scss)\z/.freeze

        # @since 0.1.0
        # @api private
        CACHE_LOCATION = Pathname(Hanami.respond_to?(:root) ? # rubocop:disable Style/MultilineTernaryOperator
                                  Hanami.root : Dir.pwd).join("tmp", "sass-cache")

        # @since 0.3.0
        # @api private
        def self.eligible?(name)
          name.to_s =~ EXTENSIONS
        end

        # @since 1.3.3
        # @api private
        def initialize(*)
          super
          require "sass-embedded"
          require "uri"
        end

        private

        # @since 0.3.0
        # @api private
        def renderer
          @renderer ||= SassRenderer.new(source, load_paths: load_paths)
        end

        # @since 0.3.0
        # @api private
        def dependencies
          renderer.dependencies
        end

        # @since 2.0.0
        # @api private
        class SassRenderer
          # @since 2.0.0
          # @api private
          FILE_URL_PARSER = URI::Parser.new({RESERVED: ";/?:@&=+$,"})

          # @since 2.0.0
          # @api private
          def initialize(source, **kwargs)
            @source = source
            @kwargs = kwargs
          end

          # @since 2.0.0
          # @api private
          def render
            result = ::Sass.compile(@source, **@kwargs)
            @loaded_urls = result.loaded_urls
            result.css
          rescue ::Sass::CompileError => exception
            @loaded_urls = exception.loaded_urls
            raise
          end

          # @since 2.0.0
          # @api private
          def dependencies
            return [] unless @loaded_urls

            @loaded_urls.filter_map do |url|
              if url.start_with?("file:")
                path = FILE_URL_PARSER.unescape(FILE_URL_PARSER.parse(url).path)
                if Gem.win_platform? && path[0].chr == "/" && path[1].chr =~ /[a-z]/i && path[2].chr == ":"
                  path = path[1..]
                end
                path
              end
            end
          end
        end
      end
    end
  end
end
