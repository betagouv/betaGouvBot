# encoding: utf-8
# frozen_string_literal: true

require 'sinatra/base'
require 'sendgrid-ruby'

module BetaGouvBot
  class Webhook < Sinatra::Base
    get '/payload' do
      # Read beta.gouv.fr members' API
      members  = HTTParty.get('https://beta.gouv.fr/api/v1/authors.json').parsed_response

      # Parse into a schedule of notifications
      schedule = Notifier.(members, Date.today)

      # Send reminders (if any)
      schedule.keys.each do |urgency|
        Mailer.(schedule[urgency], urgency)
      end
    end
  end
end
