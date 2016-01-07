require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      # Base class for JavaScript compressors
      #
      # @since 0.1.0
      # @api private
      class Javascript < Abstract
        # Factory for Javascript compressors.
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
        # @see Lotus::Assets::Configuration#javascript_compressor
        #
        # @example Basic Usage
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/javascript'
        #
        #   Lotus::Assets::Compressors::Javascript.for(:closure)
        #     # => #<Lotus::Assets::Compressors::ClosureJavascript:0x007fa32a32e108 ...>
        #
        # @example Null Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/javascript'
        #
        #   Lotus::Assets::Compressors::Javascript.for(nil)
        #     # => #<Lotus::Assets::Compressors::NullCompressor:0x007fa32a314258>
        #
        # @example Custom Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/javascript'
        #
        #   class CustomJavascriptCompressor
        #     def compress(filename)
        #       # ...
        #     end
        #   end
        #
        #   Lotus::Assets::Compressors::Javascript.for(CustomJavascriptCompressor.new)
        #     # => #<CustomJavascriptCompressor:0x007fa32a2cdf10>
        #
        # @example Third Party Compressor
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/javascript'
        #   require 'lotus/foo/compressor' # third party gem
        #
        #   Lotus::Assets::Compressors::Javascript.for(:foo)
        #     # => #<Lotus::Assets::Compressors::FooJavascript:0x007fa3dd9ed968>
        #
        # @example Unknown Engine
        #   require 'lotus/assets'
        #   require 'lotus/assets/compressors/javascript'
        #
        #   Lotus::Assets::Compressors::Javascript.for(:wat)
        #     # => Lotus::Assets::Compressors::UnknownCompressorError: Unknown Javascript compressor: :wat
        def self.for(engine_name)
          super
        end
      end
    end
  end
end
