require 'rubygems'
require 'bundler/setup'
require 'lotus/view'

Lotus::Assets.configure do
  root             __dir__ + '/..'
  public_directory __dir__ + '/../../../../tmp/standalone/public'
  prefix           '/assets'

  sources << [
    'assets'
  ]
end
