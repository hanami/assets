source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri if RUBY_VERSION >= '2.2.0'
  gem 'yard',   require: false
end

gem 'simplecov', require: false
gem 'coveralls', require: false

gem 'hanami-utils',   '~> 0.7', github: 'hanami/utils',   branch: '0.7.x'
gem 'hanami-helpers', '~> 0.3', github: 'hanami/helpers', branch: '0.3.x'
gem 'hanami-view',    '~> 0.6', github: 'hanami/view',    branch: '0.6.x'

gem 'hanami-emberjs',        path: 'test/fixtures/hanami-emberjs',        require: false
gem 'hanami-compass',        path: 'test/fixtures/hanami-compass',        require: false
gem 'hanami-foo-compressor', path: 'test/fixtures/hanami-foo-compressor', require: false
