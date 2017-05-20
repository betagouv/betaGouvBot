# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class AccountAction
    attr_accessor :name, :password

    ENDPOINT = '/email/domain/beta.gouv.fr/account'

    def initialize(name, password)
      @name     = name
      @password = password
    end

    def execute
      return if existing.length >= 1
      api.post(ENDPOINT, accountName: @name, password: @password)
    end

    private

    def existing
      api.get(ENDPOINT, accountName: @name)
    end

    def ovh
      OVH::REST
    end

    def api
      @api ||= ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
    end
  end
end
