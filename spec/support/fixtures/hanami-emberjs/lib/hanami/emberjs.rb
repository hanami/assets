# frozen_string_literal: true

require "hanami/assets"

module Hanami
  module Emberjs
    require "hanami/emberjs/version"
  end
end

Hanami::Assets.sources << __dir__ + "/emberjs/dist"
Hanami::Assets.sources << __dir__ + "/emberjs/source"
