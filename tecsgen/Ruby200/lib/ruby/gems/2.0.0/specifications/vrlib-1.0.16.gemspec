# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "vrlib"
  s.version = "1.0.16"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Cunningham"]
  s.bindir = ["."]
  s.date = "2014-01-01"
  s.description = "Library to make GUIs with Ruby.  This library is a dependency of visualruby.  This library is useful in the context of visualruby.  Go to visualruby.net to download visualruby."
  s.email = "eric@visualruby.net"
  s.homepage = "http://www.visualruby.net/"
  s.require_paths = ["."]
  s.rubyforge_project = "nowarning"
  s.rubygems_version = "2.0.14"
  s.summary = "Library to make GUIs with Ruby"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<require_all>, [">= 1.2.1"])
      s.add_runtime_dependency(%q<gtk2>, [">= 2.1.0"])
    else
      s.add_dependency(%q<require_all>, [">= 1.2.1"])
      s.add_dependency(%q<gtk2>, [">= 2.1.0"])
    end
  else
    s.add_dependency(%q<require_all>, [">= 1.2.1"])
    s.add_dependency(%q<gtk2>, [">= 2.1.0"])
  end
end
