require 'lotus/assets'

module Lotus
  module Compass
    require 'lotus/compass/version'
  end
end

Lotus::Assets.sources << __dir__ + '/compass/src'
