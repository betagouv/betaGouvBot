# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class OrganizationAction

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
  end
end
