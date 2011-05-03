# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{monocle}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Russ Smith"]
  s.date = %q{2011-05-02}
  s.description = %q{TODO: longer description of your gem}
  s.email = %q{russ@bashme.org}
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/generators/monocle/install_generator.rb",
    "lib/generators/monocle/templates/migration.rb",
    "lib/monocle.rb",
    "lib/monocle/daily_view.rb",
    "lib/monocle/monthly_view.rb",
    "lib/monocle/overall_view.rb",
    "lib/monocle/server.rb",
    "lib/monocle/view.rb",
    "lib/monocle/views.rb",
    "lib/monocle/weekly_view.rb",
    "lib/monocle/yearly_view.rb",
    "monocle.gemspec",
    "spec/db/migrate/20110502201938_create_viewables.rb",
    "spec/db/migrate/20110502223022_create_monocle_views.rb",
    "spec/spec_helper.rb",
    "spec/view_spec.rb",
    "spec/viewable_spec.rb"
  ]
  s.homepage = %q{http://github.com/russ/monocle}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{TODO: one-line summary of your gem}
  s.test_files = [
    "spec/db/migrate/20110502201938_create_viewables.rb",
    "spec/db/migrate/20110502223022_create_monocle_views.rb",
    "spec/spec_helper.rb",
    "spec/view_spec.rb",
    "spec/viewable_spec.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<database_cleaner>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<rails>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_development_dependency(%q<sinatra>, [">= 0"])
      s.add_development_dependency(%q<sqlite3>, [">= 0"])
      s.add_development_dependency(%q<shoulda-matchers>, ["= 1.0.0.beta1"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<database_cleaner>, [">= 0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<rails>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<sqlite3>, [">= 0"])
      s.add_dependency(%q<shoulda-matchers>, ["= 1.0.0.beta1"])
      s.add_dependency(%q<yard>, ["~> 0.6.0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<database_cleaner>, [">= 0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<rails>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rspec>, ["~> 2.3.0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<sqlite3>, [">= 0"])
    s.add_dependency(%q<shoulda-matchers>, ["= 1.0.0.beta1"])
    s.add_dependency(%q<yard>, ["~> 0.6.0"])
  end
end

