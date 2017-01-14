# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/anticipator'
require 'betagouvbot/mailer'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'liquid'

module BetaGouvBot
  class Webhook < Sinatra::Base
    get '/payload' do
      # Read beta.gouv.fr members' API
      members  = HTTParty.get('https://beta.gouv.fr/api/v1.1/authors.json').parsed_response

      # Parse into a schedule of notifications
      schedule = Anticipator.(members, Date.today)

      # Send reminders (if any)
      Mailer.(schedule)
    end
  end
end
