# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-utils",   "~> 2.0.alpha", git: "https://github.com/hanami/utils.git",   branch: "unstable"
gem "hanami-helpers", "~> 2.0.alpha", git: "https://github.com/hanami/helpers.git", branch: "unstable"
gem "hanami-view",    "~> 2.0.alpha", git: "https://github.com/hanami/view.git",    branch: "unstable"

gem "hanami-emberjs",        path: "spec/support/fixtures/hanami-emberjs",        require: false
gem "hanami-compass",        path: "spec/support/fixtures/hanami-compass",        require: false
gem "hanami-foo-compressor", path: "spec/support/fixtures/hanami-foo-compressor", require: false

gem "hanami-devtools", require: false, git: "https://github.com/hanami/devtools.git"
