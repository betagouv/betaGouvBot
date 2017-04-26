# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'betagouvbot/anticipator'
require 'betagouvbot/mailer'
require 'betagouvbot/sorting_hat'
require 'betagouvbot/rules'
require 'betagouvbot/badge_request'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'httparty'
require 'liquid'

module BetaGouvBot
  class Webhook < Sinatra::Base
    before do
      content_type 'application/json; charset=utf8'
    end

    helpers do
      def members
        members = HTTParty.get('https://beta.gouv.fr/api/v1.2/authors.json').parsed_response
        members.map(&:with_indifferent_access)
      end
    end

    get '/actions' do
      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Parse into a schedule of notifications
      warnings = Anticipator.(members, RULES.keys, date)

      # Send reminders (if any)
      mailer = Mailer.(warnings, RULES)

      # Reconcile mailing lists
      sorting_hat = SortingHat.(members, date)

      # Execute actions
      (mailer + sorting_hat).map(&:execute) if execute

      # Debug
      {
        "execute": execute,
        "warnings": warnings,
        "mailer": mailer,
        "sorting_hat": sorting_hat
      }.to_json
    end

    post '/badge' do
      badges = BadgeRequest.(members, params['text'])
      execute = params.key?('token') && (params['token'] == ENV['BADGE_TOKEN'])
      badges.map(&:execute) if execute
      { response_type: 'in_channel', text: 'OK, demande faite !' }.to_json
    end

    # Debug
    get '/badge' do
      { "badges": BadgeRequest.(members, params['text']) }.to_json
    end

    post '/compte' do
      accounts = AccountRequest.(members, params['text'])
      execute = params.key?('token') && (params['token'] == ENV['COMPTE_TOKEN'])
      accounts.map(&:execute) if execute
      body = { text: 'OK, création de compte en cours !' }.to_json
      headers = { 'Content-Type' => 'application/json' }
      HTTParty.post(params['response_url'], body: body, headers: headers)
    end

    # Debug
    get '/compte' do
      { "comptes": AccountRequest.(members, params['text']) }.to_json
    end
  end
end
