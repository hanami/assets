# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-utils",   "~> 1.3", git: "https://github.com/hanami/utils.git",   branch: "1.3.x"
gem "hanami-helpers", "~> 1.3", git: "https://github.com/hanami/helpers.git", branch: "1.3.x"
gem "hanami-view",    "~> 1.3", git: "https://github.com/hanami/view.git",    branch: "1.3.x"

gem "hanami-emberjs",        path: "spec/support/fixtures/hanami-emberjs",        require: false
gem "hanami-compass",        path: "spec/support/fixtures/hanami-compass",        require: false
gem "hanami-foo-compressor", path: "spec/support/fixtures/hanami-foo-compressor", require: false

gem "hanami-devtools", git: "https://github.com/hanami/devtools.git", branch: "1.3.x", require: false
