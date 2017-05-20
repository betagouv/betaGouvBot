# encoding: utf-8
# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

Dir[__dir__ + '/support/**/*.rb'].each(&method(:require))

require 'betagouvbot'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run(:focus)
  config.order = :random
end
