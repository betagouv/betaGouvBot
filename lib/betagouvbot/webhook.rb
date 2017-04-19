# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/anticipator'
require 'betagouvbot/mailer'
require 'betagouvbot/sortinghat'
require 'betagouvbot/rules'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'httparty'
require 'liquid'

module BetaGouvBot
  class Webhook < Sinatra::Base
    get '/actions' do
      content_type 'application/json; charset=utf8'

      date = params.key?('date') ? Date.iso8601(params['date']) : Date.today
      execute = params.key?('secret') && (params['secret'] == ENV['SECRET'])

      # Read beta.gouv.fr members' API
      members = HTTParty.get('https://beta.gouv.fr/api/v1.1/authors.json').parsed_response

      # Parse into a schedule of notifications
      warnings = Anticipator.(members, RULES.keys, date)

      # Send reminders (if any)
      mailer = Mailer.(warnings, RULES)

      # Reconcile mailing lists
      sorting_hat = SortingHat.(members, date)

      # Execute actions
      (mailer + sorting_hat).map(&:execute) if execute

      # Display for debugging
      {
        "execute": execute,
        "warnings": warnings,
        "mailer": mailer,
        "sorting_hat": sorting_hat
      }.to_json
    end
  end
end
