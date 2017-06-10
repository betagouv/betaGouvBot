# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  # Anticipator allows to detect, from a list of members (people), those whose contracts
  # come to and end in +terms+ days.
  #
  # @param [<#[]>] members A collection of authors.
  # @option members [String] :fullname An author's fullname.
  # @option members [String] :end An author's contact end date (yyyy/mm/dd).
  # @param [#flat_map<Integer>] terms A collection of number of days in the future.
  # @param [#+, #iso8601] date A date to be considered as a reference for comparison.
  #
  # @example
  #
  #   Anticipator.([{ fullname: 'Laure', end: '2017-05-07' }], [10], '2017-04-27'.to_date)
  #   #=> [{ term: 10, who: { fullname: 'Laure', end: '2017-05-07' } }]
  #
  # @return [<{term, who => Integer, #[]}>] A list of detected due dates grouped by
  # +terms+.
  module Anticipator
    module_function

    class << self
      def date_with_default(date_string)
        Date.iso8601(date_string)
      rescue
        Date.iso8601('3017-01-01')
      end

      def call(members, terms, date)
        end_dates = terms.map { |term| date + term }
        members
          .map { |member| member.merge(end: date_with_default(member[:end])) }
          .select { |member| end_dates.include? member[:end] }
          .map { |member| { term: (member[:end] - date).to_i, who: member } }
      end
    end
  end
end
