# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module AccountRequest
    module_function

    InvalidNameError   = Class.new(StandardError)
    InvalidEmailError  = Class.new(StandardError)

    class << self
      def call(authors, fullname, email, password)
        validate_fullname!(fullname)
        validate_email!(email)

        authors
          .select { |author| author[:id] == fullname }
          .flat_map { |author| request_account(author, email, password) }
      end

      private

      def validate_fullname!(fullname)
        fullname &&
          fullname == fullname[/\A[a-z\.\-.]+\z/] ||
          raise(InvalidNameError, 'Le format du nom doit être prenom.nom')
      end

      def validate_email!(email)
        email &&
          email =~ /\A\*?([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i ||
          raise(InvalidEmailError, 'Email invalide, typo ?')
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
        context = {}.tap do |hash|
          hash[:author]   = member
          hash[:redirect] = personal_address if redirect?(personal_address)
        end

        personal_address = personal_address[1..-1] unless redirect?(personal_address)
        [MailAction.new(client, format_mail(personal_address).(context))]
      end

      def redirect?(personal_address)
        !personal_address.start_with?('*')
      end

      def format_mail(personal_address)
        FormatMail.from_file('data/mail_compte.md', [personal_address])
      end

      def client
        nil
      end
    end
  end
end
