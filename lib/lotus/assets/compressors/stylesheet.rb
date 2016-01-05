require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      class Stylesheet < Abstract
        def self.for(value)
          case value
          when :yui
            require 'lotus/assets/compressors/yui_stylesheet'
            YuiStylesheet.new
          when :sass
            require 'lotus/assets/compressors/sass_stylesheet'
            SassStylesheet.new
          else
            super
          end
        end
      end
    end
  end
end
