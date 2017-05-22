# encoding: utf-8
# frozen_string_literal: true

require 'wisper/rspec/matchers'

RSpec.configure do |config|
  config.include(Wisper::RSpec::BroadcastMatcher)
end
