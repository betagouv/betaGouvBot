# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'
require 'ovh/rest'

module BetaGouvBot
  module SortingHat
    module_function

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # Side-effect: keeps current members subscribed to one list and alumni to another
      def call(community, date)
        begin
          sorted = sort(community, date)
          reconcile(community,members,sorted[:members],"incubateur")
          reconcile(community,alumni,sorted[:alumni],"alumni")
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end

      def sort(community, date)
        members, alumni = community.map(&:with_indifferent_access).partition {|member| Date.iso8601(member[:end]) >= date rescue true}
        {members: members, alumni: alumni}
      end

      def members
        subscribers "incubateur"
      end

      def alumni
        subscribers "alumni"
      end

      def reconcile(all,current_members,computed_members,listname)
        current_members
          .select {|email| all.any? {|author| email == email(author) } }
          .select {|email| computed_members.none? {|author| email == email(author) } }
          .each {|outgoing| unsubscribe(listname,outgoing) }
        computed_members
          .map(&:with_indifferent_access)
          .select {|author| current_members.none? {|email| email == email(author) } }
          .each {|incoming| subscribe(listname,email(incoming)) }
      end

      def ovh
        OVH::REST
      end

      def subscribe listname, email
        api.post("/email/domain/beta.gouv.fr/mailingList/#{listname}/subscriber/#{email}")
      end

      def unsubscribe listname, email
        api.delete("/email/domain/beta.gouv.fr/mailingList/#{listname}/subscriber/#{email}")
      end

      private

      def subscribers listname
        api.get("/email/domain/beta.gouv.fr/mailingList/#{listname}/subscriber")
      end

      def api
        ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
      end

      def email author
        "#{author[:id]}@beta.gouv.fr"
      end

    end
  end
end
