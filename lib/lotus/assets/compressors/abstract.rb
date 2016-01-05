require 'lotus/utils/string'
require 'lotus/utils/class'

module Lotus
  module Assets
    module Compressors
      # Abstract base class for compressors.
      #
      # Don't use this class directly, but please use subclasses instead.
      #
      # @since x.x.x
      # @api private
      class Abstract
        # Compress the given asset
        #
        # @param filename [String, Pathname] the absolute path to the asset
        #
        # @return [String] the compressed asset
        #
        # @since x.x.x
        # @api private
        def compress(filename)
          compressor.compress(
            read(filename)
          )
        end

        protected
        # @since x.x.x
        # @api private
        attr_reader :compressor

        # Read the contents of given filename
        #
        # @param filename [String, Pathname] the absolute path to the asset
        #
        # @return [String] the contents of asset
        #
        # @since x.x.x
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
        # @return [Lotus::Assets::Compress::Abstract] returns a concrete
        #   implementation of a compressor
        #
        # @since x.x.x
        # @api private
        def self.for(engine_name)
          case engine_name
          when Symbol, String
            load_engine(name, engine_name)
          when nil
            require 'lotus/assets/compressors/null_compressor'
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
        # @return [Lotus::Assets::Compress::Abstract] returns a concrete
        #   implementation of a compressor
        #
        # @since x.x.x
        # @api private
        def self.load_engine(type, engine_name)
          type = Utils::String.new(type).demodulize

          require "lotus/assets/compressors/#{ engine_name }_#{ type.underscore }"
          Utils::Class.load!("#{ Utils::String.new(engine_name).classify }#{ type }", Lotus::Assets::Compressors).new
        end

        class << self
          private :for, :load_engine
        end
      end
    end
  end
end
