# encoding: utf-8
# frozen_string_literal: true

require 'betagouvbot/mail_action'
require 'betagouvbot/mailer'
require 'betagouvbot/mail'

module BetaGouvBot
  module BadgeRequest
    module_function

    class << self
      # Input: community members
      # Side-effect: emails badge requests
      def call(members, member_id)
        members
          .select { |author| author[:id] == member_id }
          .flat_map { |member| request_badge(member) }
      end

      def request_badge(author)
        mail = Mail.from_file('data/mail_badge.md',
                              ['dinsic-sec.sgmap@modernisation.gouv.fr',
                               '{{author.id}}@beta.gouv.fr',
                               'sgmap@beta.gouv.fr'])
        [MailAction.new(client, mail.format('author' => author))]
      end

      def client
        Mailer.client
      end

    end
  end
end
