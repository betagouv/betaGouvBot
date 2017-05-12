# encoding: utf-8
# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.setup :default, :test

Dir[File.expand_path(File.join('spec', 'support', '**', '*.rb'))].map(&method(:require))

require 'betagouvbot'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run(:focus)
  config.order = :random
end
