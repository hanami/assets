# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-view", git: "https://github.com/hanami/view.git", branch: "main", require: false
gem "hanami-devtools", git: "https://github.com/hanami/devtools.git", branch: "main", require: false
