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
        members = HTTParty.get('https://beta.gouv.fr/api/v1.3/authors.json').parsed_response
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

      # Manage Github membership
      github = GithubRequest.(members, date)

      # Execute actions
      (mailer + sorting_hat + github).map(&:execute) if execute

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
      member = params['text'].split(' ').first
      origin = params['user_name']
      response = "A la demande de @#{origin} je créée un compte pour #{member}"
      body = { response_type: 'in_channel', text: response }.to_json
      headers = { 'Content-Type' => 'application/json' }
      HTTParty.post(params['response_url'], body: body, headers: headers)

      response = 'OK, création de compte en cours !'
      accounts = AccountRequest.(members, params['text'])
      execute = params.key?('token') && (params['token'] == ENV['COMPTE_TOKEN'])
      begin
        accounts.map(&:execute) if execute
      rescue StandardError => e
        response = "Zut, il y a une erreur: #{e.message}"
      end

      response = 'Je ne vois pas de qui tu veux parler' if accounts.empty?
      body = { text: response }.to_json
      headers = { 'Content-Type' => 'application/json' }
      HTTParty.post(params['response_url'], body: body, headers: headers)

      # Explicitly return empty response to suppress echoing of the command
      ''
    end

    # Debug
    get '/compte' do
      { "comptes": AccountRequest.(members, params['text']) }.to_json
    end
  end
end
