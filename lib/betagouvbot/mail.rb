# encoding: utf-8
# frozen_string_literal: true

require 'kramdown'

module BetaGouvBot
  class Mail
    attr_reader :subject, :body_t, :recipients, :sender

    # @note Email data files consist of 1 subject line plus body
    def self.from_file(body_path, recipients = [], sender = 'secretariat@beta.gouv.fr')
      subject, *rest = File.readlines(body_path)
      new(subject.strip, rest.join, recipients, sender)
    end

    def initialize(subject, body_t, recipients, sender)
      @subject    = subject
      @body_t     = body_t
      @recipients = recipients
      @sender     = sender
    end

    def format(context)
      md_source = render_template(body_t, context)
      { 'personalizations': [{
        'to': recipients.map { |mail| { 'email' => render_template(mail, context) } },
        'subject': render_template(subject, context)
      }],
        'from': { 'email' => render_template(sender, context) },
        'content': [{
          'type': 'text/html',
          'value': render_document(md_source)
        }] }
    end

    private

    def render_template(template, context)
      template_builder
        .parse(template)
        .render(context)
    end

    def render_document(md_source)
      document_builder
        .new(md_source)
        .to_html
    end

    def template_builder
      Liquid::Template
    end

    def document_builder
      Kramdown::Document
    end
  end
end
