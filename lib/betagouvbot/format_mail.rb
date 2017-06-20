# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class FormatMail
    attr_reader :subject, :body_t, :recipients, :sender

    def initialize(subject, body_t, recipients, sender)
      @subject    = subject
      @body_t     = body_t
      @recipients = recipients
      @sender     = sender
    end

    # @note Email data files consist of 1 subject line plus body
    def self.from_file(body_path, recipients = [], sender = 'secretariat@beta.gouv.fr')
      subject, *rest = File.readlines(body_path)
      new(subject.to_s.strip, rest.join, recipients, sender)
    end

    def format_message(context)
      {}.tap do |format|
        add_from(context, format)
        add_content(context, format)
        add_personalizations(context, format)
      end
    end

    def format_recipients(context)
      recipients.map { |mail| { 'email' => render_template(mail, context) } }
    end

    private

    def add_from(context, format)
      format.merge!('from' => { 'email' => render_template(sender, context) })
    end

    def add_content(context, format)
      format.merge!(
        'content' => [
          'type' => 'text/html',
          'value' => render_document(render_template(body_t, context))
        ]
      )
    end

    def add_personalizations(context, format)
      format.merge!(
        'personalizations' => [
          'to' => format_recipients(context),
          'subject' => render_template(subject, context)
        ]
      )
    end

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
