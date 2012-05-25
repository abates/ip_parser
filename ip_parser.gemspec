# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "ip_parser/version"

Gem::Specification.new do |s|
  s.name        = "ip_parser"
  s.version     = Netconf::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andrew Bates"]
  s.email       = ["abates@omeganetserv.com"]
  s.homepage    = "https://github.com/abates/ip_parser"
  s.summary     = %q{This is a ruby gem that helps parsing and manipulating IP addresses represented as strings}
  s.description = %q{see summary}

  s.rubyforge_project = ""

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
