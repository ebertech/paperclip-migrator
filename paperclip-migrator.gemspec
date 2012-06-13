# -*- encoding: utf-8 -*-
require File.expand_path('../lib/paperclip-migrator/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andrew Eberbach"]
  gem.email         = ["andrew@ebertech.ca"]
  gem.description   = %q{A gem that helps migrate paperclips to a different layout}
  gem.summary       = %q{A gem that helps migrate paperclips to a different layout}
  gem.homepage      = "https://github.com/ebertech/paperclip-migrator"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "paperclip-migrator"
  gem.require_paths = ["lib"]
  gem.version       = Paperclip::Migrator::VERSION
  
  gem.add_dependency 'activesupport'
  gem.add_dependency "clamp"
  gem.add_dependency "progressbar"
  gem.add_dependency "highline"
  gem.add_dependency "thor"
  gem.add_dependency "paperclip"
  gem.add_dependency "colored"

  gem.add_development_dependency "rspec", ">= 2.0"
  gem.add_development_dependency 'rails', "~> 2.3.14"
end
