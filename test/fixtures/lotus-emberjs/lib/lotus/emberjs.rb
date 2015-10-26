require 'lotus/assets'

module Lotus
  module Emberjs
    require 'lotus/emberjs/version'
  end
end

Lotus::Assets.sources << __dir__ + '/emberjs/dist'
Lotus::Assets.sources << __dir__ + '/emberjs/source'
