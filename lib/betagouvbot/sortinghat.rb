# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module SortingHat
    module_function

    class << self
      # Input: a date
      # Input: a list of members' arrivals and departures
      # @return [Hash<Array>] the list sorted into active members and alumni.
      def call(members, date)
        members, alumni = [[],[]]
        {members: members, alumni: alumni}
      end

    end
  end
end
