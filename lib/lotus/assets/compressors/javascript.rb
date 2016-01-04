require 'lotus/assets/compressors/abstract'

module Lotus
  module Assets
    module Compressors
      class Javascript < Abstract
        def self.for(value)
          case value
          when :yui
            require 'lotus/assets/compressors/yui_javascript'
            YuiJavascript.new
          else
            super
          end
        end
      end
    end
  end
end
