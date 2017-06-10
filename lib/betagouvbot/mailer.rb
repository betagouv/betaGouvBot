# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(warnings, rules)
        warnings.map do |warning|
          email(warning[:term], { 'author' => warning[:who] }, rules)
        end
      end

      def post(mail)
        client.post(mail)
      end

      def schedule(members, terms, date)
        end_dates = terms.map { |term| date + term }
        members
          .map { |member| member.merge(end: date_with_default(member[:end])) }
          .select { |member| end_dates.include? member[:end] }
          .map { |member| { term: (member[:end] - date).to_i, who: member } }
      end

      private

      def date_with_default(date_string)
        Date.iso8601(date_string)
      rescue
        Date.iso8601('3017-01-01')
      end

      def email(urgency, context, rules)
        mail = rules[urgency][:mail].format(context)
        MailAction.new(mail)
      end

      def recipient
        SendGrid::Email
      end

      def client
        SendGrid::API
          .new(api_key: ENV['SENDGRID_API_KEY'] || '')
          .client
          .mail
          ._('send')
      end
    end
  end
end
