# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class NotificationRule
    attr_reader :horizon, :mail_file, :recipients

    class << self
      def horizons
        all.map(&:horizon)
      end

      def all
        [in_three_weeks, in_two_weeks, in_one_day, one_day_after]
      end

      private

      def in_three_weeks
        new(21, 'data/mail_3w.md', ['{{author.id}}@beta.gouv.fr'])
      end

      def in_two_weeks
        new(14, 'data/mail_2w.md', ['{{author.id}}@beta.gouv.fr', 'contact@beta.gouv.fr'])
      end

      def in_one_day
        new(1, 'data/mail_1day.md', ['{{author.id}}@beta.gouv.fr'])
      end

      def one_day_after
        new(-1, 'data/mail_after.md', ['contact@beta.gouv.fr'])
      end
    end

    #
    # @param [Integer] horizon The rule's time horizon
    # @param [String] mail_file The path to a mail template
    # @param [<String>]] recipients Collection of rule's recipients
    #
    def initialize(horizon, mail_file, recipients)
      @horizon    = horizon
      @mail_file  = mail_file
      @recipients = recipients
    end
  end
end
