# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
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
