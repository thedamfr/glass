# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glass/version'

Gem::Specification.new do |spec|
  spec.name          = "glass"
  spec.version       = Glass::VERSION
  spec.authors       = ["TheDamFr"]
  spec.email         = ["dam.cavailles@laposte.net"]
  spec.description   = %q{Glass Gem for Google Glass}
  spec.summary       = %q{This Gem is meant to allow you to quickly build a Google Glass Application. Have Fun !}
  spec.homepage      = "https://github.com/thedamfr/glass"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "google-api-client"
end
