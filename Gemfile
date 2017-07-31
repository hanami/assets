source 'https://rubygems.org'
gemspec

unless ENV['TRAVIS']
  gem 'byebug', require: false, platforms: :mri
  gem 'yard',   require: false
end

gem 'hanami-utils',   '~> 1.0', git: 'https://github.com/hanami/utils.git',   branch: '1.0.x'
gem 'hanami-helpers', '~> 1.0', git: 'https://github.com/hanami/helpers.git', branch: '1.0.x'
gem 'hanami-view',    '~> 1.0', git: 'https://github.com/hanami/view.git',    branch: '1.0.x'

gem 'hanami-emberjs',        path: 'test/fixtures/hanami-emberjs',        require: false
gem 'hanami-compass',        path: 'test/fixtures/hanami-compass',        require: false
gem 'hanami-foo-compressor', path: 'test/fixtures/hanami-foo-compressor', require: false

gem 'rubocop', '0.48.0', require: false
gem 'coveralls',         require: false
