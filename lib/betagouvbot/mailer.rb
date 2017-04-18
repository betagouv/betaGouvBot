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
        actions = warnings.map do |warning|
          email(warning[:term], { 'author' => warning[:who] }, rules)
        end
        actions.map(&:execute) unless dry_run
        actions
      end

      def email(urgency, context, rules)
        rule = rules[urgency]
        envelope = File.read("data/envelope_#{urgency}.json")
        email = format_email(rule, envelope, context)
        MailAction.new(client, email)
      end

      def format_email(body_t, envelope_t, context)
        body = render(body_t, context)
        data = render(envelope_t, context)
        envelope = JSON.parse(data)
        envelope['content'][0]['value'] = Kramdown::Document.new(body).to_html
        envelope['content'][0]['type'] = 'text/html'
        envelope
      end

      def render(template, context)
        template = template_factory.parse(template)
        template.render(context)
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
