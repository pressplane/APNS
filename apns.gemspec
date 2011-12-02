# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{apns-pressplane}
  s.version = "0.9.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Pozdena", "Thierry Passeron", "Pressplane Inc."]
  s.autorequire = %q{apns}
  s.date = %q{2010-03-22}
  s.description = %q{Simple Apple push notification service gem}
  s.email = %q{thierry.passeron@gmail.com}
  s.extra_rdoc_files = ["MIT-LICENSE"]
  s.files = ["MIT-LICENSE", "README.textile", "Rakefile", "lib/apns", "lib/apns/core.rb", "lib/apns/payload.rb", "lib/apns.rb"]
  s.homepage = %q{http://github.com/Orion98MC/APNS}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simple Apple push notification service gem}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
