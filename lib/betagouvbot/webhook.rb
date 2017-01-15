# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/anticipator'
require 'betagouvbot/mailer'
require 'betagouvbot/sortinghat'
require 'sinatra/base'
require 'sendgrid-ruby'
require 'httparty'
require 'liquid'

module BetaGouvBot

  HORIZONS = [21, 14, 1, -1]
  RULES = Hash[HORIZONS.map{|days| [days, File.read("data/body_#{days}.txt")]}]

  class Webhook < Sinatra::Base
    get '/payload' do
      # Read beta.gouv.fr members' API
      members  = HTTParty.get('https://beta.gouv.fr/api/v1.1/authors.json').parsed_response

      # Parse into a schedule of notifications
      schedule = Anticipator.(members, RULES.keys, Date.today)

      # Send reminders (if any)
      Mailer.(schedule,RULES)

      # Reconcile mailing lists
      SortingHat.(members, Date.today)
    end
    get '/debug?:date?' do |date|
      # Read beta.gouv.fr members' API
      members  = HTTParty.get('https://beta.gouv.fr/api/v1.1/authors.json').parsed_response

      # Parse into a schedule of notifications
      debug_date = date ? Date.iso8601(date) : Date.today
      schedule = Anticipator.(members, RULES.keys, debug_date)

      # Display  reminders (if any)
      emails = Mailer.debug(schedule,RULES)
      emails
        .map(&:to_json)
        .join("\n\n")
    end
  end
end
