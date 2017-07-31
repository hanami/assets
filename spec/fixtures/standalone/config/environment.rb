require 'rubygems'
require 'bundler/setup'
require 'hanami/view'

Hanami::Assets.configure do
  root             __dir__ + '/..'
  public_directory __dir__ + '/../../../../tmp/standalone/public'
  prefix           '/assets'

  sources << [
    'assets'
  ]
end
