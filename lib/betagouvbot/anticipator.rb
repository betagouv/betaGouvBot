# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module BetaGouvBot
  module Anticipator
    module_function

    class << self
      # Input: a date
      # Input: a schedule of arrivals and departures
      # @return [Hash<Array>] a set of imminent action warnings.
      def call(members, terms, date)
        members_by_end_date = members
                              .map(&:with_indifferent_access)
                              .group_by { |item| item[:end] }
        terms.flat_map do |term|
          day = date.+(term).iso8601
          members_group = members_by_end_date[day] || []
          members_group.map do |member|
            { "term": term, "who": member }
          end
        end
      end
    end
  end
end
