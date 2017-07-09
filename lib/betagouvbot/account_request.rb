# encoding: utf-8
# frozen_string_literal: true

require 'active_model'
require 'wisper'

module BetaGouvBot
  class AccountRequest
    include ActiveModel::Validations
    include Wisper::Publisher

    attr_reader :authors, :fullname, :email, :password

    validate :validate_fullname,
             :validate_email,
             :validate_password

    def initialize(authors, fullname, email, password)
      @authors  = authors
      @fullname = fullname
      @email    = email
      @password = password
    end

    def call
      return broadcast(:error, errors.full_messages) if invalid?

      accounts.tap do |accounts|
        broadcast(:not_found) if accounts.empty?
        broadcast(:success, accounts) if accounts.present?
      end
    end

    private

    def accounts
      authors
        .select { |author| author[:id] == fullname }
        .flat_map { |author| request_account(author, email, password) }
    end

    def request_account(author, email, password)
      []
        .concat(create_account(author, password))
        .concat(create_redirection(author, email))
        .concat(create_notification(author, email))
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
      [MailAction.new('data/mail_compte.md', [personal_address], context)]
    end

    def redirect?(personal_address)
      !personal_address.start_with?('*')
    end

    def validate_fullname
      fullname &&
        fullname == fullname[/\A[a-z\.\-.]+\z/] ||
        errors.add(:base, 'Le format du nom doit être prenom.nom')
    end

    def validate_email
      email &&
        email =~ /\A\*?([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i ||
        errors.add(:base, "L'email doit être présent et être valide")
    end

    def validate_password
      password ||
        errors.add(:base, 'Le mot de passe doit être présent')
    end
  end
end
