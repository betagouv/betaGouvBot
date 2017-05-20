# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class MailingListAction
    DOMAIN = 'beta.gouv.fr'
    PREFIX = "/email/domain/#{DOMAIN}"

    def initialize(api, listname, email)
      @api = api
      @listname = listname
      @email = email
    end

    def to_s
      "#{self.class.name}, #{@listname}, #{@email}"
    end
  end

  class SubscribeAction < MailingListAction
    def execute
      endpoint = "#{PREFIX}/mailingList/#{@listname}/subscriber"
      @api.post(endpoint, email: @email)
    end
  end

  class UnsubscribeAction < MailingListAction
    def execute
      endpoint = "#{PREFIX}/mailingList/#{@listname}/subscriber/#{@email}"
      @api.delete(endpoint)
    end
  end
end
