require_relative "lib/relation/version"

Gem::Specification.new do |s|
  s.name = "relation"
  s.version = ModRelation::VERSION
  s.summary = "A lightweight relationship store for ActiveRecord models"
  s.description = <<-END
    Relation allows you to establish relationships between arbitrary
    ActiveRecord records without adding foreign keys, association columns,
    or dedicated join tables to their respective database tables.
  END
  s.authors = ["Dittmar Krall"]
  s.email = ["dittmar.krall@matiq.com"]
  s.homepage = "https://github.com/matique/relation"
  s.license = "MIT"
  s.platform = Gem::Platform::RUBY

  s.metadata["source_code_uri"] = "https://github.com/matique/relation"

  s.files = `git ls-files`.split("\n")
  s.require_paths = ["lib", "app"]
  s.required_ruby_version = ">= 3.2"

  s.add_dependency "activerecord", ">= 8.0", "< 9.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "combustion"
  s.add_development_dependency "minitest"
end
