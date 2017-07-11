# encoding: utf-8
# frozen_string_literal: true

require 'rack/test'

ENV['RACK_ENV'] ||= 'test'

module RSpecSinatra
  include Rack::Test::Methods

  def app
    BetaGouvBot::Webhook
  end
end

RSpec.configure do |config|
  config.include(RSpecSinatra)
end
