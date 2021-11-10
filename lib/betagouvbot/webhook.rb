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

      # Reconcile mailing lists
      sorting_hat = SortingHat.(members, date)

      # Execute actions
      all_actions = (sorting_hat)
      puts all_actions.map(&:execute) if execute

      # Debug
      {
        "execute": execute,
        "sorting_hat": sorting_hat
      }.to_json
    end

    ## Noop
    error StandardError do
      "Zut, il y a une erreur: #{env['sinatra.error'].message}"
    end
  end
end
