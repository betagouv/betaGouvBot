# encoding: utf-8
# frozen_string_literal: true

# External dependencies
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'
require 'httparty'
require 'kramdown'
require 'liquid'
require 'sendgrid-ruby'
require 'sinatra/base'
require 'octokit'
require 'ovh/rest'

# Internal dependencies
Dir[__dir__ + '/betagouvbot/**/*.rb'].sort.each(&method(:require))

module BetaGouvBot
  #
end
