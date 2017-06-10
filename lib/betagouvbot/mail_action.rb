# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class MailAction
    def initialize(client, mail)
      @client = client
      @mail = mail
    end

    def subject
      @mail['personalizations'][0]['subject']
    end

    def recipients
      @mail['personalizations'][0]['to']
    end

    def execute
      Mailer.post(request_body: @mail)
    end

    def to_s
      @mail.to_s
    end
  end
end
