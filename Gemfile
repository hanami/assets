# frozen_string_literal: true

source "https://rubygems.org"
gemspec

unless ENV["CI"]
  gem "byebug", require: false, platforms: :mri
  gem "yard",   require: false
end

gem "hanami-view",     github: "hanami/view",     branch: "main", require: false
gem "hanami-devtools", github: "hanami/devtools", branch: "main", require: false
