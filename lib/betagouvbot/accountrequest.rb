# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class AccountAction
    attr_accessor :name
    attr_accessor :password

    def initialize(name, password)
      @name = name
      @password = password
    end

    def execute
      accounts = api
      endpoint = '/email/domain/beta.gouv.fr/account'
      existing = accounts.get(endpoint, accountName: @name)
      return if existing.length >= 1
      accounts.post(endpoint, accountName: @name, password: @password)
    end

    def ovh
      OVH::REST
    end

    def api
      ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
    end
  end

  class RedirectAction
    attr_accessor :name
    attr_accessor :redirect

    def initialize(name, redirect)
      @name = name
      @redirect = redirect
    end

    def execute
      address = "#{@name}@beta.gouv.fr"
      redirections = api
      endpoint = '/email/domain/beta.gouv.fr/redirection'
      existing = redirections.get(endpoint, from: address)
      return if existing.length >= 1
      redirections.post(endpoint, from: address, to: @redirect, localCopy: 'false')
    end

    def ovh
      OVH::REST
    end

    def api
      ovh.new(ENV['apiKey'], ENV['appSecret'], ENV['consumerKey'])
    end
  end

  module AccountRequest
    module_function

    class << self
      def call(members, command)
        member, redirect, password = command.split(' ')
        members
          .select { |author| author[:id] == member }
          .flat_map { |author| request_account(author, redirect, password) }
      end

      def request_account(member, redirect_raw, password)
        no_redirect = redirect_raw[0] == '*'
        redirect = no_redirect ? redirect_raw[1..-1] : redirect_raw
        context = 'author' => member
        context['redirect'] = redirect unless no_redirect
        mail = Mail.from_file('data/mail_compte.md', [redirect])
        account = AccountAction.new(member[:id], password)
        redirect = RedirectAction.new(member[:id], redirect)
        notify = MailAction.new(client, mail.format(context))
        no_redirect ? [account, notify] : [account, redirect, notify]
      end

      def client
        Mailer.client
      end
    end
  end
end
