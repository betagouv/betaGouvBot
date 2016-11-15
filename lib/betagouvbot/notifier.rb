# encoding: utf-8
# frozen_string_literal: true

require 'active_support/core_ext/hash/indifferent_access'

module BetaGouvBot
  module Notifier
    module_function

    class << self
      def call(members, date)
        {}.tap do |result|
          by_date           = by_date(members)
          tomorrow          = date.+(1).iso8601
          soon              = date.+(10).iso8601

          result[:tomorrow] = result(by_date, tomorrow) if by_date[tomorrow]
          result[:soon]     = result(by_date, soon)     if by_date[soon]
        end
      end

      private

      def by_date(members)
        members
          .map(&:with_indifferent_access)
          .group_by { |item| item[:end] }
      end

      def result(by_date, date)
        by_date[date].map { |author| author[:fullname] }
      end
    end
  end
end
