require 'hanami/assets/compressors/stylesheet'

module Hanami
  module Assets
    module Compressors
      # Builtin compressor for stylesheet
      #
      # This is a basic algorithm based on Scott Becker (@sbecker) work on
      # <tt>asset_packager</tt> gem.
      #
      # Copyright (c) 2006-2008 Scott Becker
      #
      # @since 0.1.0
      # @api private
      #
      # @see https://github.com/sbecker/asset_packager
      class BuiltinStylesheet < Stylesheet
        # @since 0.1.0
        # @api private
        SPACE_REPLACEMENT                = " ".freeze

        # @since 0.1.0
        # @api private
        COMMENTS_REPLACEMENT             = "".freeze

        # @since 0.1.0
        # @api private
        LINE_BREAKS_REPLACEMENT          = "}\n".freeze

        # @since 0.1.0
        # @api private
        LAST_BREAK_REPLACEMENT           = "".freeze

        # @since 0.1.0
        # @api private
        INSIDE_LEFT_BRACKET_REPLACEMENT  = " {".freeze

        # @since 0.1.0
        # @api private
        INSIDE_RIGHT_BRACKET_REPLACEMENT = "}".freeze

        # @since 0.1.0
        # @api private
        def compress(filename)
          result = read(filename)
          result.gsub!(/\s+/,            SPACE_REPLACEMENT)                # collapse space
          result.gsub!(/\/\*(.*?)\*\/ /, COMMENTS_REPLACEMENT)             # remove comments - caution, might want to remove this if using css hacks
          result.gsub!(/\} /,            LINE_BREAKS_REPLACEMENT)          # add line breaks
          result.gsub!(/\n$/,            LAST_BREAK_REPLACEMENT)           # remove last break
          result.gsub!(/ \{ /,           INSIDE_LEFT_BRACKET_REPLACEMENT)  # trim inside brackets
          result.gsub!(/; \}/,           INSIDE_RIGHT_BRACKET_REPLACEMENT) # trim inside brackets
          result
        end
      end
    end
  end
end
