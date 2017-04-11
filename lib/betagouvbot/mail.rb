# encoding: utf-8
# frozen_string_literal: true

require 'kramdown'

module BetaGouvBot
  class Mail
    def initialize(subject, body_fn, recipients = [], senders = ['bot@beta.gouv.fr'])
      @subject = subject
      @body_fn = body_fn
      @recipients = recipients
      @senders = senders
    end

    def body_fn=(body_fn)
      @body_fn = body_fn
      @body_t = File.read("data/#{body_fn}") if @body_fn
    end

    def format(context)
      md_source = self.class.render(@body_t, context)
      { "personalizations": [{
        'to': @recipients.map { |mail| { 'email' => self.class.render(mail, context) } },
        'subject': self.class.render(@subject, context)
      }],
        'from': @senders.map { |mail| { 'email' => self.class.render(mail, context) } },
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
