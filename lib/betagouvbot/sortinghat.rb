# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'ovh/rest'
require 'betagouvbot/mailinglistaction'

module BetaGouvBot
  module SortingHat
    module_function

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # Side-effect: keeps current members subscribed to one list and alumni to another
      def call(community, date, dry_run = false)
        community = community.map(&:with_indifferent_access)
        sorted = sort(community, date)
        actions = reconcile(community, members, sorted[:members], 'incubateur') +
                  reconcile(community, alumni, sorted[:alumni], 'alumni')
        actions.map(&:execute) unless dry_run
        actions
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

      def unsubscribe_current(all, current_members, computed_members, listname)
        current_members
          .select { |email| all.any? { |author| email == email(author) } }
          .select { |email| computed_members.none? { |author| email == email(author) } }
          .each { |outgoing| unsubscribe(listname, outgoing) }
      end

      def subscribe_new(current_members, computed_members, listname)
        computed_members
          .map(&:with_indifferent_access)
          .select { |author| current_members.none? { |email| email == email(author) } }
          .each { |incoming| subscribe(listname, email(incoming)) }
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

    end
  end
end
