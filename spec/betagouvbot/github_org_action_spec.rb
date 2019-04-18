# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::GithubOrgAction do
  describe 'granting membership on Github' do
    subject       { instance_spy('api') }

    let(:octokit) { instance_double('octokit', new: subject) }
    let(:action)  { described_class.new('betagouv', 'ann-gh', 12) }

    before { allow(action).to receive(:octokit) { octokit } }

    it 'checks existing membership' do
      action.execute
      is_expected.to have_received(:organization_member?).with('betagouv', 'ann-gh')
    end

    context 'when already a member of the org' do
      before { allow(action).to receive(:organization_member?) { true } }

      it 'leaves the user alone' do
        action.execute
        is_expected.not_to have_received(:add_team_membership)
      end
    end

    context 'when not a member of the org' do
      before { allow(action).to receive(:organization_member?) { false } }

      it 'invites the user to the org and team' do
        action.execute
        is_expected.to have_received(:add_team_membership).with(12, 'ann-gh')
      end
    end
  end
end
