# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "atk"
  s.version = "2.2.3"
  s.platform = "x86-mingw32"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["The Ruby-GNOME2 Project Team"]
  s.date = "2014-10-26"
  s.description = "Ruby/ATK is a Ruby binding of ATK-1.0.x."
  s.email = "ruby-gnome2-devel-en@lists.sourceforge.net"
  s.homepage = "http://ruby-gnome2.sourceforge.jp/"
  s.licenses = ["LGPLv2.1 or later"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.0.14"
  s.summary = "Ruby/ATK is a Ruby binding of ATK-1.0.x."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<glib2>, ["= 2.2.3"])
    else
      s.add_dependency(%q<glib2>, ["= 2.2.3"])
    end
  else
    s.add_dependency(%q<glib2>, ["= 2.2.3"])
  end
end
