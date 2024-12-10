require 'hanami/cyg_utils/string'
require 'hanami/cyg_utils/class'

module Hanami
  module Assets
    module Compressors
      # Unknown compressor error
      #
      # It's raised when trying to load an unknown compressor.
      #
      # @since 0.1.0
      # @api private
      #
      # @see Hanami::Assets::Configuration#javascript_compressor
      # @see Hanami::Assets::Configuration#stylesheet_compressor
      # @see Hanami::Assets::Compressors::Abstract#for
      class UnknownCompressorError < Error
        # @since 0.1.0
        # @api private
        def initialize(type, engine_name)
          super("Unknown #{ type } compressor: :#{ engine_name }")
        end
      end

      # Abstract base class for compressors.
      #
      # Don't use this class directly, but please use subclasses instead.
      #
      # @since 0.1.0
      # @api private
      class Abstract
        # Compress the given asset
        #
        # @param filename [String, Pathname] the absolute path to the asset
        #
        # @return [String] the compressed asset
        #
        # @since 0.1.0
        # @api private
        def compress(filename)
          compressor.compress(
            read(filename)
          )
        end

        protected
        # @since 0.1.0
        # @api private
        attr_reader :compressor

        # Read the contents of given filename
        #
        # @param filename [String, Pathname] the absolute path to the asset
        #
        # @return [String] the contents of asset
        #
        # @since 0.1.0
        # @api private
        def read(filename)
          ::File.read(filename)
        end

        private

        # Factory for compressors.
        #
        # It loads a compressor for the given name.
        #
        # @abstract Please use this method from the subclasses
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
        def self.for(engine_name)
          case engine_name
          when Symbol, String
            load_engine(name, engine_name)
          when nil
            require 'hanami/assets/compressors/null_compressor'
            NullCompressor.new
          else
            engine_name
          end
        end

        # Load the compressor for the given type and engine name.
        #
        # @param type [String] asset type (eg. "Javascript" or "Stylesheet")
        # @param engine_name [Symbol,String] the name of the engine to load (eg. `:yui`)
        #
        # @return [Hanami::Assets::Compress::Abstract] returns a concrete
        #   implementation of a compressor
        #
        # @since 0.1.0
        # @api private
        def self.load_engine(type, engine_name)
          type = CygUtils::String.demodulize(type)

          require "hanami/assets/compressors/#{ engine_name }_#{ CygUtils::String.underscore(type) }"
          CygUtils::Class.load!("#{ CygUtils::String.classify(engine_name) }#{ type }", Hanami::Assets::Compressors).new
        rescue LoadError
          raise UnknownCompressorError.new(type, engine_name)
        end

        class << self
          private :for, :load_engine
        end
      end
    end
  end
end
