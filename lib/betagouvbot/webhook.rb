# encoding: utf-8
# frozen_string_literal: true

require 'sinatra/base'
require 'sendgrid-ruby'

module BetaGouvBot
  class Webhook < Sinatra::Base
    post '/payload' do
      # Read beta.gouv.fr members' API
      members  = HTTParty.get('https://beta.gouv.fr/api/v1/authors.json').parsed_response

      # Parse into a schedule of notifications
      schedule = Notifier.(members, Date.today)

      # Send remainders (if any)
      Mailer.(schedule[:tomorrow], 'demain') if schedule[:tomorrow]
      Mailer.(schedule[:soon], 'dans 10 jours') if schedule[:soon]
    end
  end
end
