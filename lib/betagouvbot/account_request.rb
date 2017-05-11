# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module AccountRequest
    module_function

    InvalidNameError   = Class.new(StandardError)
    InvalidEmailError  = Class.new(StandardError)
    EmptyPasswordError = Class.new(StandardError)

    class << self
      def call(authors, params)
        fullname, email, password = params.split
        validate_fullname!(fullname)
        validate_email!(email)
        validate_password!(password)

        authors
          .select { |author| author[:id] == fullname }
          .flat_map { |author| request_account(author, email, password) }
      end

      private

      def validate_fullname!(fullname)
        fullname &&
          fullname == fullname[/\A[a-z\.\-.]+\z/] ||
          raise(InvalidNameError, 'Author name format should be prenom.nom')
      end

      def validate_email!(email)
        email &&
          email =~ /\A\*?([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i ||
          raise(InvalidEmailError, "That's not a valid email, maybe a typo?")
      end

      def validate_password!(password)
        password || raise(EmptyPasswordError, 'Password is required')
      end

      def request_account(author, email, password)
        create_account(author, password) +
          create_redirection(author, email) +
          create_notification(author, email)
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
