# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'ovh/rest'

module BetaGouvBot
  module SortingHat
    module_function

    DOMAIN = 'beta.gouv.fr'

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # Side-effect: keeps current members subscribed to one list and alumni to another
      def call(community, date, dry_run = false)
        sorted = sort(community, date)
        {
          "incubateur": reconcile(community, members, sorted[:members], 'incubateur',
                                  dry_run),
          "alumni": reconcile(community, alumni, sorted[:alumni], 'alumni', dry_run)
        }
      rescue => e
        puts e.message
        puts e.backtrace.inspect
      end

      def active?(member, date)
        Date.iso8601(member[:end]) >= date
      rescue
        true
      end

      def sort(community, date)
        community = community.map(&:with_indifferent_access)
        members, alumni = community.partition { |member| active? member, date }
        { members: members, alumni: alumni }
      end

      def members
        subscribers 'incubateur'
      end

      def alumni
        subscribers 'alumni'
      end

      def reconcile(all, current_members, computed_members, listname, dry_run = false)
        {
          "unsubscribe": unsubscribe_current(all, current_members,
                                             computed_members, listname, dry_run),
          "subscribe": subscribe_new(current_members, computed_members,
                                     listname, dry_run)
        }
      end

      def unsubscribe_current(all, current_members, computed_members, listname,
                              dry_run = false)
        current_members
          .select { |email| all.any? { |author| email == email(author) } }
          .select { |email| computed_members.none? { |author| email == email(author) } }
          .each { |outgoing| unsubscribe(listname, outgoing, dry_run) }
      end

      def subscribe_new(current_members, computed_members, listname, dry_run = false)
        computed_members
          .map(&:with_indifferent_access)
          .select { |author| current_members.none? { |email| email == email(author) } }
          .each { |incoming| subscribe(listname, email(incoming), dry_run) }
      end

      def ovh
        OVH::REST
      end

      def subscribe(listname, email, dry_run = false)
        endpoint = "/email/domain/#{DOMAIN}/mailingList/#{listname}/subscriber"
        dry_run ? email : api.post(endpoint, email: email)
      end

      def unsubscribe(listname, email, dry_run = false)
        endpoint = "/email/domain/#{DOMAIN}/mailingList/#{listname}/subscriber/#{email}"
        dry_run ? email : api.delete(endpoint)
      end

      private

      def subscribers(listname)
        endpoint = "/email/domain/#{DOMAIN}/mailingList/#{listname}/subscriber"
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
