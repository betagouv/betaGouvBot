# encoding: utf-8
# frozen_string_literal: true

module BetaGouvBot
  class GithubOrgAction
    attr_accessor :org, :user, :team

    def initialize(org, user, team)
      @org  = org
      @user = user
      @team = team
    end

    def execute
      return if organization_member?
      api.add_team_membership(@team, @user)
    end

    def to_s
      "#{self.class.name}, #{@user}, #{@org}, #{@team}"
    end

    private

    def organization_member?
      api.organization_member?(@org, @user)
    end

    def api
      @api ||= octokit.new(access_token: ENV['GITHUB_TOKEN'] || '')
    end

    def octokit
      Octokit::Client
    end
  end
end
