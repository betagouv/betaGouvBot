# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'betagouvbot/version'

Gem::Specification.new do |spec|
  spec.name          = 'betagouvbot'
  spec.version       = BetaGouvBot::VERSION
  spec.authors       = ['Morendil', 'maukoquiroga', 'l-vincent-l']
  spec.email         = ['betagouvbot@beta.gouv.fr']

  spec.summary       = 'Automated assistant for beta.gouv.fr administrative tasks.'
  spec.homepage      = 'https://github.com/sgmap/betagouvbot'
  spec.license       = 'AGPL-3.0'

  spec.files         = Dir['{lib,data}/**/*', 'README*', 'Rakefile', 'config.ru']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'kramdown'
  spec.add_runtime_dependency 'liquid'
  spec.add_runtime_dependency 'octokit'
  spec.add_runtime_dependency 'ovh-rest'
  spec.add_runtime_dependency 'rack', '< 2'
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'sendgrid-ruby'
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'thin'
  spec.add_runtime_dependency 'wisper'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-collection_matchers'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop', '= 0.49.1'
  spec.add_development_dependency 'rubocop-rspec', '= 1.15.1'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'wisper-rspec'
end
