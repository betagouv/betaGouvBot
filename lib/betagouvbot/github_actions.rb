# encoding: utf-8
# frozen_string_literal: true

require 'octokit'

module BetaGouvBot
  module GithubRequest
    module_function

    BETA_GOUV_FR = '2348627'

    class << self
      def call(community, date)
        active = SortingHat.sort(community, date)[:members]
        active
          .reject { |member| member[:github].nil? || member[:github].empty? }
          .map { |member| OrganizationAction.new('sgmap', member[:github], BETA_GOUV_FR) }
      end
    end
  end

  class OrganizationAction
    attr_accessor :org, :user, :team

    def initialize(org, user, team)
      @org = org
      @user = user
      @team = team
    end

    def execute
      return if api.organization_member?(@org, @user)
      api.add_team_member(@team, @user)
    end

    def octokit
      Octokit::Client
    end

    def api
      @api ||= octokit.new(ENV['GITHUB_TOKEN'] || '')
    end

    def to_s
      "#{self.class.name}, #{@user}, #{@org}, #{@team}"
    end
  end
end
