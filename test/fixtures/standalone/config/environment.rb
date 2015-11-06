require 'rubygems'
require 'bundler/setup'
require 'lotus/view'

Lotus::Assets.configure do
  root        __dir__ + '/..'
  destination __dir__ + '/../../../../tmp/standalone/public/assets'
  prefix  '/'

  sources << [
    'assets'
  ]
end
