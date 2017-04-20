# encoding: utf-8
# frozen_string_literal: true

require 'redis'
require 'active_support/core_ext/hash/indifferent_access'
require 'betagouvbot/mailaction'
require 'betagouvbot/procaction'
require 'betagouvbot/mailer'
require 'betagouvbot/mail'

module BetaGouvBot
  module BadgeRequest
    module_function

    class << self
      # Input: community members
      # Side-effect: emails badge requests
      def call(members)
        members
          .map(&:with_indifferent_access)
          .select { |member| needs_badge_request?(member) }
          .flat_map { |member| request_badge(member) }
      end

      def needs_badge_request?(author)
        range = "#{author[:start]}-#{author[:end]}"
        previous = state_storage["#{author[:id]}_badge"]
        needs_update = !previous || (previous != range)
        based_here = author[:based] == 'dinsic'
        based_here && needs_update
      end

      def request_badge(author)
        mail = Mail.from_file('data/mail_badge.md',
                              ['{{author.id}}@beta.gouv.fr}}', 'sgmap@beta.gouv.fr'])
        mailaction = MailAction.new(client, mail.format('author' => author))
        state_update = ProcAction.new do
          state_storage["#{author[:id]}_badge"] = "#{author[:start]}-#{author[:end]}"
        end
        [mailaction, state_update]
      end

      def client
        Mailer.client
      end

      def state_storage
        Redis.new
      end

    end
  end
end
