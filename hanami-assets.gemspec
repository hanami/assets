# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hanami/assets/version'

Gem::Specification.new do |spec|
  spec.name          = 'hanami-assets'
  spec.version       = Hanami::Assets::VERSION
  spec.authors       = ['Luca Guidi', 'Trung Lê', 'Alfonso Uceda']
  spec.email         = ['me@lucaguidi.com', 'trung.le@ruby-journal.com', 'uceda73@gmail.com']
  spec.summary       = %q{Assets management}
  spec.description   = %q{Assets management for Ruby web applications}
  spec.homepage      = 'http://hanamirb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -- lib/* bin/* CHANGELOG.md LICENSE.md README.md hanami-assets.gemspec`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'hanami-utils',    '~> 0.7'
  spec.add_runtime_dependency 'hanami-helpers',  '~> 0.3'
  spec.add_runtime_dependency 'tilt',            '~> 2.0', '>= 2.0.2'

  spec.add_development_dependency 'bundler',          '~> 1.6'
  spec.add_development_dependency 'rake',             '~> 10'
  spec.add_development_dependency 'minitest',         '~> 5'

  spec.add_development_dependency 'yui-compressor',   '~> 0.12'
  spec.add_development_dependency 'uglifier',         '~> 2.7'
  spec.add_development_dependency 'closure-compiler', '~> 1.1'
  spec.add_development_dependency 'sass',             '~> 3.4'

  spec.add_development_dependency 'coffee-script',    '~> 2.3'
  spec.add_development_dependency 'babel-transpiler', '~> 0.7'
end
