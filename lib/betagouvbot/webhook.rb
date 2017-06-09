# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'httparty'

module BetaGouvBot
  class Webhook < Sinatra::Base
    before { content_type 'application/json; charset=utf8' }

    helpers do
      def members
        HTTParty
          .get('https://beta.gouv.fr/api/v1.3/authors.json')
          .parsed_response
          .map(&:with_indifferent_access)
      end
    end

    get '/actions' do
      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Parse into a schedule of notifications
      warnings = Anticipator.(members, NotificationRule.horizons, date)

      # Send reminders (if any)
      mailer = Mailer.(warnings, NotificationRule.all)

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
        "sorting_hat": sorting_hat,
        "github": github
      }.to_json
    end

    post '/badge' do
      badges  = BadgeRequest.(members, params['text'])
      execute = params.key?('token') && (params['token'] == ENV['BADGE_TOKEN'])
      badges.map(&:execute) if execute
      { response_type: 'in_channel', text: 'OK, demande faite !' }.to_json
    end

    # Debug
    get '/badge' do
      { "badges": BadgeRequest.(members, params['text']) }.to_json
    end

    post '/compte' do
      member   = params['text'].to_s.split.first
      origin   = params['user_name']
      response = "A la demande de @#{origin} je créée un compte pour #{member}"
      body     = { response_type: 'in_channel', text: response }.to_json
      HTTParty.post(params['response_url'], body: body, headers: headers)

      response = 'OK, création de compte en cours !'
      accounts = AccountRequest.(members, *params['text'].to_s.split)
      execute  = params.key?('token') && (params['token'] == ENV['COMPTE_TOKEN'])
      accounts.map(&:execute) if execute

      response = 'Je ne vois pas de qui tu veux parler' if accounts.empty?
      body     = { text: response }.to_json
      HTTParty.post(params['response_url'], body: body, headers: headers)

      # Explicitly return empty response to suppress echoing of the command
      ''
    end

    # Debug
    get '/compte' do
      { "comptes": AccountRequest.(members, *params['text'].to_s.split) }.to_json
    end

    ## Noop
    error StandardError do
      "Zut, il y a une erreur: #{env['sinatra.error'].message}"
    end
  end
end
