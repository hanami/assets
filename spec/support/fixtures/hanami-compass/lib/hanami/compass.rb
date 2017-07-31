require 'hanami/assets'

module Hanami
  module Compass
    require 'hanami/compass/version'
  end
end

Hanami::Assets.sources << __dir__ + '/compass/src'
