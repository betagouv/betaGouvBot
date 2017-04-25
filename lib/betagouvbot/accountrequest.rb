# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class AccountAction
    attr_accessor :name
    attr_accessor :redirect
    def initialize(name, redirect)
      @name = name
      @redirect = redirect
    end
  end
  module AccountRequest
    module_function

    class << self
      def call(members, command)
        member, redirect = command.split(' ')
        members
          .select { |author| author[:id] == member }
          .flat_map { |author| request_account(author, redirect) }
      end

      def request_account(member, redirect)
        mail = Mail.from_file('data/mail_compte.md', [redirect])
        notify = MailAction.new(client, mail.format('author' => member))
        perform = AccountAction.new(member[:id], redirect)
        [perform, notify]
      end

      def client
        Mailer.client
      end
    end
  end
end
