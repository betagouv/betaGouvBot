# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module NotificationRequest
    module_function

    class << self
      def call(members, date)
        warnings(members, date)
          .map { |warning| email({ 'author' => warning[:who] }, rule(warning[:term])) }
      end

      def schedule(members, terms, date)
        end_dates = terms.map { |term| date + term }
        members
          .map { |member| member.merge(end: date_with_default(member[:end])) }
          .select { |member| end_dates.include? member[:end] }
          .map { |member| { term: (member[:end] - date).to_i, who: member } }
      end

      private

      def warnings(members, date)
        schedule(members, horizons, date)
      end

      def horizons
        NotificationRule.horizons
      end

      def rule(urgency)
        NotificationRule.find(horizon: urgency)
      end

      def date_with_default(date_string)
        Date.iso8601(date_string)
      rescue
        Date.iso8601('3017-01-01')
      end

      def email(context, rule)
        MailAction.new(format_mail(rule.mail_file, rule.recipients, context))
      end

      def format_mail(mail_file, recipients, context)
        FormatMail
          .from_file(mail_file, recipients)
          .(context)
      end
    end
  end
end
