# -*- encoding: utf-8 -*-
require File.expand_path('../lib/data_mapper/twowaysql/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Takumi IINO"]
  gem.email         = ["trot.thunder@gmail.com"]
  gem.summary       = "DataMapper plugin providing support for TwoWaySQL."
  gem.description   = gem.summary
  gem.homepage      = "http://github.com/troter/dm-twowaysql"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dm-twowaysql"
  gem.require_paths = ["lib"]
  gem.version       = DataMapper::TwoWaySQL::VERSION

  gem.add_runtime_dependency('dm-do-adapter', '~> 1.2.0')
  gem.add_runtime_dependency('twowaysql', '~> 0.5.0')

  gem.add_development_dependency('rake', '~> 0.9.2')
  gem.add_development_dependency('rspec', '~> 1.3.2')
end
