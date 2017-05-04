# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class AccountAction
    attr_accessor :name
    attr_accessor :password

    ENDPOINT = '/email/domain/beta.gouv.fr/account'

    def initialize(name, password)
      @name = name
      @password = password
    end

    def execute
      return if existing.length >= 1
      api.post(ENDPOINT, accountName: @name, password: @password)
    end

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

  module AccountRequest
    module_function

    class << self
      def call(members, command)
        member, personal_address, password = command.split(' ')
        members
          .select { |author| author[:id] == member }
          .flat_map { |author| request_account(author, personal_address, password) }
      end

      def request_account(member, personal_address, password)
        create_account(member, password) +
          create_redirection(member, personal_address) +
          create_notification(member, personal_address)
      end

      def create_account(member, password)
        [AccountAction.new(member[:id], password)]
      end

      def create_redirection(member, target)
        redirect?(target) ? [RedirectAction.new(member[:id], target)] : []
      end

      def create_notification(member, personal_address)
        context = { 'author' => member }
        context['redirect'] = personal_address if redirect?(personal_address)
        personal_address = personal_address[1..-1] unless redirect?(personal_address)
        mail = Mail.from_file('data/mail_compte.md', [personal_address])
        [MailAction.new(client, mail.format(context))]
      end

      def redirect?(personal_address)
        !personal_address.start_with?('*')
      end

      def client
        Mailer.client
      end
    end
  end
end
