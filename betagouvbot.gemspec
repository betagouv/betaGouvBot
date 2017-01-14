# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'betagouvbot/version'

Gem::Specification.new do |spec|
  spec.name          = 'betagouvbot'
  spec.version       = BetaGouvBot::VERSION
  spec.authors       = ['Morendil']
  spec.email         = ['betagouvbot@beta.gouv.fr']

  spec.summary       = 'Alert email webhook.'
  spec.homepage      = 'https://github.com/sgmap/betagouvbot'
  spec.license       = 'AGPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'rack', '< 2'
  spec.add_runtime_dependency 'sendgrid-ruby'
  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'liquid'
  spec.add_runtime_dependency 'thin'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
