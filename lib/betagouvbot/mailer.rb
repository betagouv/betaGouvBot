# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(warnings)
        warnings
          .map { |warning| email({ 'author' => warning[:who] }, rule(warning[:term])) }
      end

      def post(mail)
        client.post(mail)
      end

      private

      def email(context, rule)
        MailAction.new(format_mail(rule.mail_file, rule.recipients, context))
      end

      def rule(urgency)
        NotificationRule.find(horizon: urgency)
      end

      def format_mail(mail_file, recipients, context)
        FormatMail
          .from_file(mail_file, recipients)
          .(context)
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
