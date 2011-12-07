# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "voterable/version"

Gem::Specification.new do |s|
  s.name        = "voterable"
  s.version     = Voterable::VERSION
  s.authors     = ["Ben"]
  s.email       = ["benguest@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Mongoid dependant user voting rating}
  s.description = %q{Hackish implementaiton of voting on of voteable objects by a voter}

  s.rubyforge_project = "voterable"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:

  # General Dependency's
  s.add_dependency "mongoid", ["2.3.0"]
  s.add_dependency "bson", ["= 1.4.0"]
  s.add_dependency "bson_ext", ["= 1.4.0"]

  #Testing
  s.add_development_dependency "rspec"
  s.add_development_dependency "factory_girl", ["~> 2.1.0"]

  #Automated Testing
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-spork"  
  s.add_development_dependency "database_cleaner"

  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency "growl"

  #Documentation
  s.add_development_dependency "rdoc"

  # s.add_runtime_dependency "rest-client"
end
