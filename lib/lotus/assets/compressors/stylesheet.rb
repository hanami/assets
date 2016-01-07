require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      # Base class for stylesheet compressors
      #
      # @since 0.1.0
      # @api private
      class Stylesheet < Abstract
        # Factory for Stylesheet compressors.
        #
        # It loads a compressor for the given name.
        #
        # @param engine_name [Symbol,String,NilClass,#compress] the name of the
        #   engine to load or an instance of an engine
        #
        # @return [Lotus::Assets::Compressors::Abstract] returns a concrete
        #   implementation of a compressor
        #
        # @raise [Lotus::Assets::Compressors::UnknownCompressorError] when the
        #   given name refers to an unknown compressor engine
        #
        # @since 0.1.0
        # @api private
        #
        # @see Lotus::Assets::Compressors::Abstract#for
        # @see Lotus::Assets::Configuration#stylesheet_compressor
        #
        # @example Basic Usage
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/stylesheet'
        #
        #   Lotus::Assets::Compressors::Stylesheet.for(:sass)
        #     # => #<Lotus::Assets::Compressors::SassStylesheet:0x007f8674cc4a50 ...>
        #
        # @example Null Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/stylesheet'
        #
        #   Lotus::Assets::Compressors::Stylesheet.for(nil)
        #     # => #<Lotus::Assets::Compressors::NullCompressor:0x007fa32a314258>
        #
        # @example Custom Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/stylesheet'
        #
        #   class CustomStylesheetCompressor
        #     def compress(filename)
        #       # ...
        #     end
        #   end
        #
        #   Lotus::Assets::Compressors::Stylesheet.for(CustomStylesheetCompressor.new)
        #     # => #<CustomStylesheetCompressor:0x007fa32a2cdf10>
        #
        # @example Third Party Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/stylesheet'
        #   require 'lotus/foo/compressor' # third party gem
        #
        #   Lotus::Assets::Compressors::Stylesheet.for(:foo)
        #     # => #<Lotus::Assets::Compressors::FooStylesheet:0x007fa3dd9ed968>
        #
        # @example Unknown Engine
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/stylesheet'
        #
        #   Lotus::Assets::Compressors::Stylesheet.for(:wat)
        #     # => Lotus::Assets::Compressors::UnknownCompressorError: Unknown Stylesheet compressor: :wat
        def self.for(engine_name)
          super
        end
      end
    end
  end
end
