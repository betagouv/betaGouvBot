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

          [1,10,14,21].each do |how_soon|
            the_day = date.+(how_soon).iso8601
            result[how_soon] = by_date[the_day] if by_date[the_day]
          end
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
