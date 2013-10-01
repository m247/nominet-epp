# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nominet-epp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Geoff Garside"]
  gem.email         = ["geoff@geoffgarside.co.uk"]
  gem.description   = %q{Client for communicating with the Nominet EPP}
  gem.summary       = %q{Nominet EPP (Extensible Provisioning Protocol) Client}
  gem.homepage      = "https://github.com/m247/nominet-epp"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nominet-epp"
  gem.require_paths = ["lib"]
  gem.version       = NominetEPP::VERSION

  gem.extra_rdoc_files = %w(LICENSE README.md HISTORY.md)

  gem.add_dependency 'epp-client', '>= 0.1.0'
end
