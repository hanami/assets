# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/assets/version'

Gem::Specification.new do |spec|
  spec.name          = "lotus-assets"
  spec.version       = Lotus::Assets::VERSION
  spec.authors       = ["Benny Klotz"]
  spec.email         = ["r3qnbenni@gmail.com"]
  spec.summary       = %q{Asset Pipeline for lotus}
  spec.description   = %q{Asset Pipeline for lotus}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'tilt'
  spec.add_dependency 'sass'
  spec.add_dependency 'less'
  spec.add_dependency 'coffee-script'
  spec.add_dependency 'therubyracer'

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
