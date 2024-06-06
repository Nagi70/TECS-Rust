# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "glib2"
  s.version = "2.2.3"
  s.platform = "x86-mingw32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["The Ruby-GNOME2 Project Team"]
  s.date = "2014-10-26"
  s.description = "Ruby/GLib2 is a Ruby binding of GLib-2.x."
  s.email = "ruby-gnome2-devel-en@lists.sourceforge.net"
  s.homepage = "http://ruby-gnome2.sourceforge.jp/"
  s.licenses = ["LGPLv2.1 or later"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.0.14"
  s.summary = "Ruby/GLib2 is a Ruby binding of GLib-2.x."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<pkg-config>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, [">= 2"])
      s.add_runtime_dependency(%q<cairo>, [">= 1.12.8"])
    else
      s.add_dependency(%q<pkg-config>, [">= 0"])
      s.add_dependency(%q<test-unit>, [">= 2"])
      s.add_dependency(%q<cairo>, [">= 1.12.8"])
    end
  else
    s.add_dependency(%q<pkg-config>, [">= 0"])
    s.add_dependency(%q<test-unit>, [">= 2"])
    s.add_dependency(%q<cairo>, [">= 1.12.8"])
  end
end
