# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class AccountAction
    attr_accessor :name
    attr_accessor :redirect

    def initialize(name, redirect, password)
      @name = name
      @redirect = redirect
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
  module AccountRequest
    module_function

    class << self
      def call(members, command)
        member, redirect, password = command.split(' ')
        members
          .select { |author| author[:id] == member }
          .flat_map { |author| request_account(author, redirect, password) }
      end

      def request_account(member, redirect, password)
        mail = Mail.from_file('data/mail_compte.md', [redirect])
        notify = MailAction.new(client, mail.format('author' => member))
        perform = AccountAction.new(member[:id], redirect, password)
        [perform, notify]
      end

      def client
        Mailer.client
      end
    end
  end
end
