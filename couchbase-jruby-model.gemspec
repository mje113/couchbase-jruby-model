# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'couchbase/model/version'

Gem::Specification.new do |s|
  s.name        = 'couchbase-jruby-model'
  s.version     = Couchbase::Model::VERSION
  s.author      = 'Couchbase'
  s.email       = 'support@couchbase.com'
  s.homepage    = 'https://github.com/mje113/couchbase-jruby-model'
  s.summary     = %q{Declarative interface to Couchbase (unofficial--targeting JRuby)}
  s.description = %q{ORM-like interface allows you to persist your models to Couchbase}
  s.license     = 'Apache'
  s.platform    = Gem::Platform::JAVA

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'couchbase-jruby-client', '~> 0.1'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'activesupport'
end
