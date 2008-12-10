# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{elementor}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2008-11-19}
  s.email = %q{patnakajima@gmail.com}
  s.files = [
    "lib/elementor",
    "lib/elementor.rb",
    "lib/elementor/spec.rb",
    "lib/elementor/element_set.rb",
    "lib/elementor/result.rb",
    "lib/core_ext",
    "lib/core_ext/object.rb",
    "lib/core_ext/kernel.rb",
    "lib/core_ext/symbol.rb"
  ]
  s.homepage = %q{http://github.com/nakajima/elementor}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{Prettier element traversal with Nokogiri}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<nokogiri>, [">= 0"])
    else
      s.add_dependency(%q<nokogiri>, [">= 0"])
    end
  else
    s.add_dependency(%q<nokogiri>, [">= 0"])
  end
end
