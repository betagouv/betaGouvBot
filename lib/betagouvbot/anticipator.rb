# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Anticipator
    module_function

    class << self
      def call(members, terms, date)
        members_by_end_date = members.group_by { |item| item[:end] }
        terms.flat_map do |term|
          day = date.+(term).iso8601
          members_group = members_by_end_date[day] || []
          members_group.map do |member|
            { term: term, who: member }
          end
        end
      end
    end
  end
end
