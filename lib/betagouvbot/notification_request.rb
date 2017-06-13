# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module NotificationRequest
    module_function

    class << self
      def call(members, date)
        warnings(members, date).map do |warning|
          email({ 'author' => warning[:who] }, rule(warning[:term]))
        end
      end

      private

      def warnings(members, date)
        NotificationSchedule.(members, end_dates(date))
      end

      def end_dates(date)
        NotificationRule
          .horizons
          .map { |horizon| date + horizon }
      end

      def rule(urgency)
        NotificationRule.find(horizon: urgency)
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
