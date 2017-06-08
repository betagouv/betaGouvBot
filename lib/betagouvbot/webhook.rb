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
      def authors
        HTTParty
          .get('https://beta.gouv.fr/api/v1.3/authors.json')
          .parsed_response
          .map(&:with_indifferent_access)
      end

      def broadcast_acknowledge(origin, member, callback)
        response = "À la demande de @#{origin} je crée un compte pour #{member}"
        body     = { response_type: 'in_channel', text: response }.to_json
        HTTParty.post(callback, body: body, headers: headers)
      end

      def broadcast_success(callback)
        response = 'OK, création de compte en cours !'
        body     = { text: response }.to_json
        HTTParty.post(callback, body: body, headers: headers)
      end

      def broadcast_errors(errors, callback)
        response = "Zut, il y a une ou plusieurs erreur(s) : #{errors.join(', ')}"
        body     = { text: response }.to_json
        HTTParty.post(callback, body: body, headers: headers)
      end
    end

    get '/actions' do
      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Parse into a schedule of notifications
      warnings = Anticipator.(authors, FormatMail.to_rules.keys, date)

      # Send reminders (if any)
      mailer = Mailer.(warnings, FormatMail.to_rules)

      # Reconcile mailing lists
      sorting_hat = SortingHat.(authors, date)

      # Manage Github authorship
      github = GithubRequest.(authors, date)

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
      badges  = BadgeRequest.(authors, params['text'])
      execute = params.key?('token') && (params['token'] == ENV['BADGE_TOKEN'])
      badges.map(&:execute) if execute
      { response_type: 'in_channel', text: 'OK, demande faite !' }.to_json
    end

    # Debug
    get '/badge' do
      { "badges": BadgeRequest.(authors, params['text']) }.to_json
    end

    post '/compte' do
      params['response_url'].present? || error(400, "'response_url' doit être présente")
      params['user_name'].present?    || error(400, "'user_name' doit être présent")
      params['token'].present?        || error(400, "'token' doit être présent")

      params['token'] == ENV['COMPTE_TOKEN'] || error(401, "'token' n'est pas valide")

      unless params['text'].present?
        error(422, '/compte prenom.nom [*]mail@truc.com passw (* = sans redir)')
      end

      member, email, password = params['text'].to_s.split

      broadcast_acknowledge(params['user_name'], member, params['response_url'])

      account_request = AccountRequest.new(authors, member, email, password)

      account_request.on(:success) do |accounts|
        accounts.map(&:execute)
        broadcast_success(params['response_url'])
        halt(200)
      end

      account_request.on(:not_found) do
        error(404, 'je ne vois pas de qui tu veux parler')
      end

      account_request.on(:error) do |errors|
        error(422, errors)
      end

      account_request.()
    end

    # Debug
    get '/compte' do
      { "comptes": AccountRequest.(authors, *params['text'].to_s.split) }.to_json
    end

    ## Error handling

    error 400, 401, 404, 422 do
      broadcast_errors(body, params['response_url']) if params['response_url'].present?
      halt([200, headers, { code: status, errors: body }.to_json])
    end
  end
end
