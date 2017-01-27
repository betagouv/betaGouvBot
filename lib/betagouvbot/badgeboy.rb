# encoding: utf-8
# frozen_string_literal: true

require 'redis'
require 'active_support/core_ext/hash/indifferent_access'

module BetaGouvBot
  module BadgeBoy
    module_function

    class << self
      # Input: community members
      # Side-effect: emails badge requests
      def call(members)
        members
          .map(&:with_indifferent_access)
          .select { |member| member[:based] == 'dinsic' }
          .each { |member| maybe_request_badge(member) }
      end

      def maybe_request_badge(author)
        key = "#{author[:id]}_badge_request"
        previous = state_storage[key]
        return if previous
        range = "#{author[:start]}-#{author[:end]}"
        state_storage[key] = range
        request_badge(author)
      end

      def request_badge(author)
        envelope = File.read('data/envelope_badge.json')
        body = File.read('data/body_badge.txt')
        email = mailer.format_email(envelope, body, author)
        mailer.post(email)
      end

      def state_storage
        Redis.new
      end

      def mailer
        BetaGouvBot::Mailer
      end
    end
  end
end
