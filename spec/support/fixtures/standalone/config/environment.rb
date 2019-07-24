require "rubygems"
require "bundler/setup"
require "hanami/view"

Hanami::Assets.configure do
  root             "spec/support/fixtures/standalone"
  public_directory "spec/tmp/standalone/public"
  prefix           "/assets"

  sources << [
    "assets"
  ]
end
