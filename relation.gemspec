$:.push File.expand_path("../lib", __FILE__)
require 'relation/miscellaneous'

Gem::Specification.new do |s|
  s.name        = 'relation'
  s.version     = VERSION
  s.authors     = ['Dittmar Krall']
  s.email       = ['dittmar.krall@matique.de']
  s.homepage    = 'https://github.com/matique/relation'
  s.summary     = %q{Provides a simple directed relationship between active_record models.}
  s.description = %q{A gem that adds simple support for organizing ActiveRecord models.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "activerecord"

  # Dependencies (installed via 'bundle install')...
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "minitest"
  s.add_development_dependency "simplecov"
end
