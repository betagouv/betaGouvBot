# encoding: utf-8
# frozen_string_literal: true

require 'ovh/rest'
require 'betagouvbot/mailinglistaction'
require 'betagouvbot/mailer'
require 'betagouvbot/mailaction'
require 'betagouvbot/mailer'

module BetaGouvBot
  module SortingHat
    module_function

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # Side-effect: keeps current members subscribed to one list and alumni to another
      def call(community, date)
        sorted = sort(community, date)
        reconcile(community, members, sorted[:members], 'incubateur') +
          reconcile(community, alumni, sorted[:alumni], 'alumni')
      end

      def active?(member, date)
        Date.iso8601(member[:end]) >= date
      rescue
        true
      end

      def sort(community, date)
        members, alumni = community.partition { |member| active? member, date }
        { members: members, alumni: alumni }
      end

      def members
        subscribers 'incubateur'
      end

      def alumni
        subscribers 'alumni'
      end

      def reconcile(all, current_members, computed_members, listname)
        unsubscribe_current(all, current_members, computed_members, listname) +
          subscribe_new(current_members, computed_members, listname)
      end

      def unsubscribe_current(all, current, target, listname)
        leaving = current
                  .select { |email| all.any? { |author| email == email(author) } }
                  .select { |email| target.none? { |author| email == email(author) } }

        leaving.map { |outgoing| unsubscribe(listname, outgoing) } +
          leaving.map { |outgoing| notify(false, listname, author(all, outgoing)) }
      end

      def subscribe_new(current, target, listname)
        arriving = target
                   .map(&:with_indifferent_access)
                   .select { |author| current.none? { |email| email == email(author) } }
        arriving.map { |incoming| subscribe(listname, email(incoming)) } +
          arriving.map { |incoming| notify(true, listname, incoming) }
      end

      def notify(subscribed, listname, author)
        description = subscribed ? 'abonné.e à' : 'désabonné.e de'
        operation = subscribed ? 'Abonnement à' : 'Désabonnement de'
        mail = Mail.from_file('data/mail_subscribed.md',
                              ['{{author.id}}@beta.gouv.fr'])
        BetaGouvBot::MailAction.new(Mailer.client,
                                    mail.format('author' => author,
                                                'operation' => operation,
                                                'description' => description,
                                                'listname' => listname))
      end

      def ovh
        OVH::REST
      end

      def subscribe(listname, email)
        SubscribeAction.new(api, listname, email)
      end

      def unsubscribe(listname, email)
        UnsubscribeAction.new(api, listname, email)
      end

      private

      def subscribers(listname)
        endpoint = "#{MailingListAction::PREFIX}/mailingList/#{listname}/subscriber"
        api.get(endpoint)
      end

      def api
        ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
      end

      def email(author)
        "#{author[:id]}@beta.gouv.fr"
      end

      def author(community, email)
        community.detect { |author| email == email(author) }
      end

    end
  end
end
