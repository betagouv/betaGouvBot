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

      def email(urgency, context, rules)
        mail = rules[urgency][:mail].format(context)
        MailAction.new(client, mail)
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
