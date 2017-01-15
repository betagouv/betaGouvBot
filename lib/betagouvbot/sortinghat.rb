# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module BetaGouvBot
  module SortingHat
    module_function

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # @return [Hash<Array>] the list sorted into active members and alumni.
      def call(community, date)
        members, alumni = community.map(&:with_indifferent_access).partition {|member| Date.iso8601(member[:end]) >= date}
        {members: members, alumni: alumni}
      end

    end
  end
end
