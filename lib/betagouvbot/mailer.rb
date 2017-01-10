# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    PHRASE = { 1 => 'demain', 10 => 'dans 10 jours', 21 => 'dans 3 semaines' }.freeze

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(expirations)
        expirations
          .map { |urgency, members| email(urgency, members) }
          .each { |mail| client.post(request_body: mail.to_json) }
      end

      def email(urgency, members)
        from    = SendGrid::Email.new(email: 'betagouvbot@beta.gouv.fr')
        to      = urgency == 21 ?
                      recipient.new(email: members[0]["id"] + '@beta.gouv.fr')
                    : recipient.new(email: 'contact@beta.gouv.fr')
        subject = 'Rappel: arrivée à échéance de contrats !'
        content = content(urgency, members)
        SendGrid::Mail.new(from, subject, to, content)
      end

      def content(urgency, members)
        names = members.map {|h| h["fullname"]}
        SendGrid::Content.new(
          type: 'text/plain',
          value: %(
            Les contrats de #{names.join(', ')} arrivent à échéance #{PHRASE[urgency]}

            -- BetaGouvBot
          )
        )
      end

      def recipient
        SendGrid::Email
      end

      def client
        SendGrid::API
          .new(api_key: ENV['SENDGRID_API_KEY'])
          .client
          .mail
          ._('send')
      end
    end
  end
end
