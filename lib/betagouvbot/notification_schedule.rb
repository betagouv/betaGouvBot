# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module NotificationSchedule
    module_function

    class << self
      def call(members, end_dates)
        members
          .reject { |member| member[:end].blank? }
          .map    { |member| member.merge(end: to_date(member[:end])) }
          .select { |member| end_dates.include?(member[:end]) }
          .map    { |member| { term: (member[:end] - Date.today).to_i, who: member } }
      end

      private

      def to_date(date_string)
        Date.iso8601(date_string)
      end
    end
  end
end
