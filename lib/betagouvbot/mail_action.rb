# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class MailAction
    def initialize(mail_template, recipients, context)
      @mail = FormatMail.from_file(mail_template, recipients)
      @context = context
    end

    def subject
      @mail.subject
    end

    def recipients
      @mail.format_recipients(@context)
    end

    def formatted_mail
      @mail.(@context)
    end

    def execute
      client.post(request_body: formatted_mail)
    end

    def to_s
      formatted_mail.to_s
    end

    def api
      SendGrid::API
    end

    def client
      api
        .new(api_key: ENV['SENDGRID_API_KEY'] || '')
        .client
        .mail
        ._('send')
    end
  end
end
