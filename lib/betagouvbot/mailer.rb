# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    class << self
      def call(members, urgency)
        from    = SendGrid::Email.new(email: 'betagouvbot@beta.gouv.fr')
        to      = SendGrid::Email.new(email: 'contact@beta.gouv.fr')
        subject = 'Rappel: arrivée à échéance de contrats !'
        content = content(members, urgency)
        mail    = SendGrid::Mail.new(from, subject, to, content)

        client.post(request_body: mail.to_json)
      end

      private

      def content(members, urgency)
        SendGrid::Content.new(
          type: 'text/plain',
          value: %(
            Les contrats de #{members.join(', ')} arrivent à échéance #{urgency}

            -- BetaGouvBot
          )
        )
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
