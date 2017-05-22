# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'httparty'
require 'liquid'

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

      def publish_error(message)
        "Zut, il y a une ou plusieurs erreur(s) : #{message}".tap do |response|
          HTTParty.post(
            params['response_url'],
            body: { text: response }.to_json,
            headers: headers
          )
        end
      end
    end

    get '/actions' do
      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Parse into a schedule of notifications
      warnings = Anticipator.(members, FormatMail.to_rules.keys, date)

      # Send reminders (if any)
      mailer = Mailer.(warnings, FormatMail.to_rules)

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
      halt(400, "'response_url' doit être présent") unless params['response_url']
      halt(400, "'user_name' doit être présent") unless params['user_name']
      halt(400, "'text' doit être présent") unless params['text']
      halt(400, "'token' doit être présent") unless params['token']
      halt(401, "'token' n'est pas valide") unless params['token'] == ENV['COMPTE_TOKEN']

      member   = params['text'].to_s.split.first
      origin   = params['user_name']
      response = "À la demande de @#{origin} je crée un compte pour #{member}"
      body     = { response_type: 'in_channel', text: response }.to_json
      HTTParty.post(params['response_url'], body: body, headers: headers)

      account_request = AccountRequest.new

      account_request.on(:success) do |accounts|
        accounts.map(&:execute)
        response = 'OK, création de compte en cours !'
        body     = { text: response }.to_json
        HTTParty.post(params['response_url'], body: body, headers: headers)
        [201, headers, body]
      end

      account_request.on(:not_found) do
        error 404, 'Je ne vois pas de qui tu veux parler'
      end

      account_request.on(:error) do
        error 422, 'pene' # TODO: add error message
      end

      account_request.(members, *params['text'].to_s.split)
    end

    # Debug
    get '/compte' do
      { "comptes": AccountRequest.(members, *params['text'].to_s.split) }.to_json
    end

    ## Error handling

    error 400, 401, 404, 422 do
      publish_error(body.join(', ')) if params['response_url']
      [status, headers, { errors: body }.to_json]
    end

    # error 500 do
    #   publish_error(env['sinatra.error'].message) if params['response_url']
    #   [status, headers, { errors: [env['sinatra.error'].message] }.to_json]
    # end
  end
end
