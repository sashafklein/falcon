# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'falcon/version'

Gem::Specification.new do |spec|
  spec.name          = "falcon"
  spec.version       = Falcon::VERSION
  spec.authors       = ["Sasha Klein"]
  spec.email         = ["sashafklein@gmail.com"]

  spec.summary       = %q{A Heroku wrapper to simplify and de-risk app deployment, migrations, and rollbacks.}
  spec.homepage      = "http://www.sashafklein.com/portfolio#falcon"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['falcon']
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
