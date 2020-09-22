# frozen_string_literal: true

require "hanami/assets/compressors/javascript"

module Hanami
  module Assets
    module Compressors
      class FooJavascript < Javascript
        def compress(filename)
        end
      end
    end
  end
end
