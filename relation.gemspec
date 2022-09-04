$:.push File.expand_path("../lib", __FILE__)
require "relation/version"

Gem::Specification.new do |s|
  s.name = "relation"
  s.version = ModRelation::VERSION
  s.summary = <<-'END'
    Provides a simple directed relationship between active_record models.
  END
  s.description = <<-'END'
    A Rails gem that adds simple support for organizing ActiveRecord models.
  END
  s.authors = ["Dittmar Krall"]
  s.email = ["dittmar.krall@matiq.com"]
  s.homepage = "https://matiq.com"
  s.license = "MIT"
  s.platform = Gem::Platform::RUBY

  s.metadata["source_code_uri"] = "https://github.com/matique/relation"

  s.files = `git ls-files`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib", "app"]

  s.add_dependency "activerecord"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "appraisal"

  s.add_development_dependency "minitest"
  s.add_development_dependency "sqlite3"
end
