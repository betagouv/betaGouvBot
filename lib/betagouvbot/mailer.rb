# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module Mailer
    module_function

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(expirations, rules)
        expirations
          .flat_map { |urgency, members|
            members.map { |author| email(urgency, author, rules) }
          }
          .each { |mail| client.post(request_body: mail) }
      end

      def debug(expirations, rules)
        expirations
          .flat_map { |urgency, members|
            members.map { |author| email(urgency, author, rules) }
          }
      end

      def email(urgency, author, rules)
        body = body(urgency, author, rules)
        template = File.read("data/envelope_#{urgency}.json")
        ready = template_factory.parse(template)
        data = ready.render("author" => author)
        envelope = JSON.parse(data)
        envelope["content"][0]["value"] = body
        envelope
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
