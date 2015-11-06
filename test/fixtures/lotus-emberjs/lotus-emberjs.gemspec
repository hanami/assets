# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lotus/emberjs/version'

Gem::Specification.new do |spec|
  spec.name          = "lotus-emberjs"
  spec.version       = Lotus::Emberjs::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]

  spec.summary       = %q{Test gem}
  spec.description   = %q{Test to simulate Lotus::Assets integration with third part gems}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = ["lib/lotus/emberjs.rb", "lib/lotus/emberjs/version.rb", "lib/lotus/emberjs/dist/ember.js"]
  spec.require_paths = ["lib"]

  # spec.add_dependency             "lotus-assets", "~> 0.1"
  spec.add_development_dependency "bundler",      "~> 1.10"
  spec.add_development_dependency "rake",         "~> 10.0"
end
