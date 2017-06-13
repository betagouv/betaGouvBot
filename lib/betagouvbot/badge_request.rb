# encoding: utf-8
# frozen_string_literal: true

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

      private

      def request_badge(author)
        MailAction.new(format_mail('author' => author))
      end

      def format_mail(context)
        @format_mail ||= FormatMail.from_file('data/mail_badge.md', recipients)
        @format_mail.(context)
      end

      def recipients
        %w[
          dinsic-sec.sgmap@modernisation.gouv.fr
          {{author.id}}@beta.gouv.fr
          sgmap@beta.gouv.fr
        ]
      end
    end
  end
end
