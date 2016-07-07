source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils',   '~> 0.8', github: 'hanami/utils',   branch: '0.8.x'
gem 'hanami-helpers', '~> 0.4', github: 'hanami/helpers', branch: '0.4.x'
gem 'hanami-view',    '~> 0.7', github: 'hanami/view',    branch: '0.7.x'

gem 'hanami-emberjs',        path: 'test/fixtures/hanami-emberjs',        require: false
gem 'hanami-compass',        path: 'test/fixtures/hanami-compass',        require: false
gem 'hanami-foo-compressor', path: 'test/fixtures/hanami-foo-compressor', require: false

gem 'rubocop', '~> 0.41', require: false
gem 'coveralls',          require: false
