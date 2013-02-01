# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skip32/version'

Gem::Specification.new do |gem|
  gem.name          = "skip32"
  gem.version       = Skip32::VERSION
  gem.authors       = ["Kevin Gilpin", "Chen ZhongXue"]
  gem.email         = ["kgilpin@gmail.com", "xmpolaris@gmail.com"]
  gem.summary       = %q{32-bit block cipher and Crockford 32-bit encoding in PL/SQL}
  gem.homepage      = ""
  
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'integer-obfuscator'
  gem.add_development_dependency 'base32-crockford'
  gem.add_development_dependency 'activerecord'
  gem.add_development_dependency 'sequel'
  gem.add_development_dependency 'pg'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
