# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "monocle/version"

Gem::Specification.new do |s|
  s.name = %q{monocle}
  s.version = Monocle::VERSION
  s.authors = ["Russ Smith (russ@bashme.org)"]
  s.date = %q{2011-08-31}
  s.description = %q{A history of view events.}
  s.email = %q{russ@bashme.org}
  s.homepage = %q{http://github.com/russ/monocle}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A history of view events.}
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.add_dependency('activesupport', '>= 2.3.10')
  s.add_dependency('redis', '>= 2.2.2')
  s.add_dependency('sinatra', '>= 0')
end
