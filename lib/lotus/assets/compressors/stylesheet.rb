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
          else
            super
          end
        end
      end
    end
  end
end
