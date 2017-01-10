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
      def call(members, date)
        {}.tap do |result|
          by_date           = by_date(members)

          result[1]  = by_date[date.+(1).iso8601]  if by_date[date.+(1).iso8601]
          result[10] = by_date[date.+(10).iso8601] if by_date[date.+(10).iso8601]
          result[21] = by_date[date.+(21).iso8601] if by_date[date.+(21).iso8601]
        end
      end

      private

      def by_date(members)
        members
          .map(&:with_indifferent_access)
          .group_by { |item| item[:end] }
      end

    end
  end
end
