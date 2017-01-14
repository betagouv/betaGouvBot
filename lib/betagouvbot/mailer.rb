# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    STOCK = %(
            Le contrat de {{author.fullname}} arrive à échéance le {{author.end}}

            -- BetaGouvBot
          )
    RULES = {1 => STOCK, 10 => STOCK, 21 => STOCK}

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(expirations)
        expirations
          .flat_map { |urgency, members|
            members.map { |author| email(urgency, author, RULES) }
          }
          .each { |mail| client.post(request_body: mail.to_json) }
      end

      def debug(expirations)
        expirations
          .flat_map { |urgency, members|
            members.map { |author| email(urgency, author, RULES) }
          }
      end

      def email(urgency, author, rules)
        from    = SendGrid::Email.new(email: 'betagouvbot@beta.gouv.fr')
        to      = urgency == 21 ?
                      recipient.new(email: author["id"] + '@beta.gouv.fr')
                    : recipient.new(email: 'contact@beta.gouv.fr')
        subject = 'Rappel: arrivée à échéance de contrats !'
        body = body(urgency, author, rules)
        content = content(body)
        mail = SendGrid::Mail.new(from, subject, to, content)
      end

      def body(urgency, author, rules)
        template = template_factory.parse(rules[urgency])
        template.render("author" => author)
      end

      def content(body)
        SendGrid::Content.new(
          type: 'text/plain',
          value: body
        )
      end

      def template_factory
        Liquid::Template
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
