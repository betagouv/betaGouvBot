# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class RedirectAction
    attr_accessor :name
    attr_accessor :redirect

    ENDPOINT = '/email/domain/beta.gouv.fr/redirection'

    def initialize(name, redirect)
      @name = name
      @redirect = redirect
    end

    def execute
      existing = redirections
      if existing.length >= 1
        update = "#{ENDPOINT}/#{existing[0]}/changeRedirection"
        api.post(update, to: @redirect)
      else
        api.post(ENDPOINT, from: address, to: @redirect, localCopy: 'false')
      end
    end

    def redirections
      api.get(ENDPOINT, from: address)
    end

    def address
      "#{@name}@beta.gouv.fr"
    end

    def ovh
      OVH::REST
    end

    def api
      @api ||= ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
    end
  end
end
