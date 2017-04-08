# encoding: utf-8
# frozen_string_literal: true
require 'betagouvbot/mailaction'
require 'kramdown'

module BetaGouvBot
  module Mailer
    module_function

    class << self
      # @param expirations [#:[]] expiration dates mapped to members
      def call(warnings, rules, dry_run = false)
        actions = warnings.map { |warning| email(warning[:term], warning[:who], rules) }
        actions.map(&:execute) unless dry_run
        actions
      end

      def email(urgency, author, rules)
        rule = rules[urgency]
        envelope = File.read("data/envelope_#{urgency}.json")
        email = format_email(rule, envelope, author)
        MailAction.new(client, email)
      end

      def format_email(body_t, envelope_t, author)
        body = render(body_t, author)
        data = render(envelope_t, author)
        envelope = JSON.parse(data)
        envelope['content'][0]['value'] = content(body)
        envelope
      end

      def render(template, author)
        template = template_factory.parse(template)
        template.render('author' => author)
      end

      def content(body)
        SendGrid::Content.new(
          type: 'text/html',
          value: Kramdown::Document.new(body).to_html
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
