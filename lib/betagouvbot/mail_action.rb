# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class MailAction
    def initialize(mail)
      @mail = mail
    end

    def subject
      @mail['personalizations'][0]['subject']
    end

    def recipients
      @mail['personalizations'][0]['to']
    end

    def execute
      client.post(request_body: @mail)
    end

    def to_s
      @mail.to_s
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
