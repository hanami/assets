# frozen_string_literal: true

require "hanami/assets/compressors/stylesheet"

module Hanami
  module Assets
    module Compressors
      class FooStylesheet < Stylesheet
        def compress(filename)
        end
      end
    end
  end
end
