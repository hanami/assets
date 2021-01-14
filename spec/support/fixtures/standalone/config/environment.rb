# frozen_string_literal: true

require "rubygems"
require "bundler/setup"
require "hanami/view"

Hanami::Assets.configure do
  root             "spec/support/fixtures/standalone"
  public_directory "tmp/standalone/public"
  prefix           "/assets"

  sources << [
    "assets"
  ]
end
