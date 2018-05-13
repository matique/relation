$:.push File.expand_path('../lib', __FILE__)
require 'relation/version'

Gem::Specification.new do |s|
  s.name        = 'relation'
  s.version     = ModRelation::VERSION
  s.summary     = <<-'END'
    Provides a simple directed relationship between active_record models.
  END
  s.description = <<-'END'
    A Rails gem that adds simple support for organizing ActiveRecord models.
  END
  s.authors     = ['Dittmar Krall']
  s.email       = ['dittmar.krall@matique.de']
  s.homepage    = 'https://github.com/matique/relation'

  s.license     = 'MIT'
  s.platform    = Gem::Platform::RUBY

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.test_files    = `git ls-files -- {test,features}/*`.split("\n")
  s.require_paths = ['lib', 'app']

  s.add_dependency 'activerecord', '~> 0'

  s.add_development_dependency 'appraisal', '~> 0'
  s.add_development_dependency 'bundler', '~> 0'
  s.add_development_dependency 'rake', '~> 0'

  s.add_development_dependency 'minitest', '~> 0'
  s.add_development_dependency 'simplecov', '~> 0'
  s.add_development_dependency 'sqlite3', '~> 0'
end
