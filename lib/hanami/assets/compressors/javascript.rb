require 'hanami/assets/compressors/abstract'

module Hanami
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
        # @return [Hanami::Assets::Compressors::Abstract] returns a concrete
        #   implementation of a compressor
        #
        # @raise [Hanami::Assets::Compressors::UnknownCompressorError] when the
        #   given name refers to an unknown compressor engine
        #
        # @since 0.1.0
        # @api private
        #
        # @see Hanami::Assets::Compressors::Abstract#for
        # @see Hanami::Assets::Configuration#javascript_compressor
        #
        # @example Basic Usage
        #   require 'hanami/assets'
        #   require 'hanami/assets/compressors/javascript'
        #
        #   Hanami::Assets::Compressors::Javascript.for(:closure)
        #     # => #<Hanami::Assets::Compressors::ClosureJavascript:0x007fa32a32e108 ...>
        #
        # @example Null Compressor
        #   require 'hanami/assets'
        #   require 'hanami/assets/compressors/javascript'
        #
        #   Hanami::Assets::Compressors::Javascript.for(nil)
        #     # => #<Hanami::Assets::Compressors::NullCompressor:0x007fa32a314258>
        #
        # @example Custom Compressor
        #   require 'hanami/assets'
        #   require 'hanami/assets/compressors/javascript'
        #
        #   class CustomJavascriptCompressor
        #     def compress(filename)
        #       # ...
        #     end
        #   end
        #
        #   Hanami::Assets::Compressors::Javascript.for(CustomJavascriptCompressor.new)
        #     # => #<CustomJavascriptCompressor:0x007fa32a2cdf10>
        #
        # @example Third Party Compressor
        #   require 'hanami/assets'
        #   require 'hanami/assets/compressors/javascript'
        #   require 'hanami/foo/compressor' # third party gem
        #
        #   Hanami::Assets::Compressors::Javascript.for(:foo)
        #     # => #<Hanami::Assets::Compressors::FooJavascript:0x007fa3dd9ed968>
        #
        # @example Unknown Engine
        #   require 'hanami/assets'
        #   require 'hanami/assets/compressors/javascript'
        #
        #   Hanami::Assets::Compressors::Javascript.for(:wat)
        #     # => Hanami::Assets::Compressors::UnknownCompressorError: Unknown Javascript compressor: :wat
        def self.for(engine_name)
          super
        end
      end
    end
  end
end
