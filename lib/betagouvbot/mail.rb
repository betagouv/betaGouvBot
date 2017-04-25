# encoding: utf-8
# frozen_string_literal: true

require 'kramdown'

module BetaGouvBot
  class Mail

    attr_accessor :subject
    attr_accessor :recipients

    def self.from_file(body_path, recipients = [], sender = 'secretariat@beta.gouv.fr')
      # Email data files consist of 1 subject line plus body
      subject, *rest = File.readlines(body_path)
      Mail.new(subject.strip, rest.join, recipients, sender)
    end

    def initialize(subject, body_t, recipients, sender)
      @subject = subject
      @body_t = body_t
      @recipients = recipients
      @sender = sender
    end

    def format(context)
      md_source = self.class.render(@body_t, context)
      { 'personalizations': [{
        'to': @recipients.map { |mail| { 'email' => self.class.render(mail, context) } },
        'subject': self.class.render(@subject, context)
      }],
        'from': { 'email' => self.class.render(@sender, context) },
        'content': [{
          'type': 'text/html',
          'value': Kramdown::Document.new(md_source).to_html
        }] }
    end

    def self.template_factory
      Liquid::Template
    end

    def self.render(template, context)
      template = template_factory.parse(template)
      template.render(context)
    end
  end
end
