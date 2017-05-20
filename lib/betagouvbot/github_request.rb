# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  module GithubRequest
    module_function

    BETA_GOUV_FR = '2348627'

    class << self
      def call(community, date)
        active = SortingHat.sort(community, date)[:members]
        active
          .reject { |member| member[:github].nil? || member[:github].empty? }
          .map { |member| GithubOrgAction.new('sgmap', member[:github], BETA_GOUV_FR) }
      end
    end
  end
end
