# encoding: utf-8
# frozen_string_literal: true

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

      def respond_in_channel(response, url)
        body = { response_type: 'in_channel', text: response }.to_json
        HTTParty.post(url, body: body)
      end

      def respond(response, url)
        body = { text: response }.to_json
        HTTParty.post(url, body: body)
      end
    end

    get '/actions' do
      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Send contract expiration reminders (if any)
      notifications = NotificationRequest.(members, date)

      # Reconcile mailing lists
      sorting_hat = SortingHat.(members, date)

      # Manage Github membership
      github = GithubRequest.(members, date)

      # Execute actions
      all_actions = (notifications + sorting_hat + github)
      all_actions.map(&:execute) if execute

      # Debug
      {
        "execute": execute,
        "notifications": notifications,
        "sorting_hat": sorting_hat,
        "github": github
      }.to_json
    end

    post '/compte' do
      member, email, password = params['text'].to_s.split
      account_request         = AccountRequest.new(members, member, email, password)

      account_request.on(:success) do |accounts|
        origin   = params['user_name']
        response = "A la demande de @#{origin} je créée un compte pour #{member}"
        respond_in_channel(response, params['response_url'])

        execute = params.key?('token') && (params['token'] == ENV['COMPTE_TOKEN'])
        begin
          accounts.map(&:execute) if execute
          respond('OK, création de compte en cours !', params['response_url'])
        rescue StandardError => e
          respond("Zut, il y a une erreur: #{e.message}", params['response_url'])
        end
      end

      account_request.on(:not_found) do
        respond('Je ne vois pas de qui tu veux parler', params['response_url'])
      end

      account_request.on(:error) do |errors|
        respond(errors.first, params['response_url'])
        raise(StandardError, errors.first)
      end

      account_request.()

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
