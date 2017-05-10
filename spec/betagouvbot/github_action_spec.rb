# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::OrganizationAction do
  describe 'granting membership on Github' do
    let(:octokit)   { instance_spy('octokit') }
    let(:api)       { instance_spy('api') }
    let(:action)    { described_class.new('sgmap', 'ann-gh', 12) }

    before do
      allow(action).to receive(:octokit) { octokit }
      allow(octokit).to receive(:new) { api }
      allow(api).to receive(:organization_member?)
    end

    it 'checks existing membership' do
      action.execute
      expect(api).to have_received(:organization_member?).with('sgmap', 'ann-gh')
    end

    context 'when already a member of the org' do
      before do
        allow(api).to receive(:organization_member?) { true }
      end
      it 'leaves the user alone' do
        action.execute
        expect(api).to have_received(:organization_member?).with('sgmap', 'ann-gh')
        expect(api).not_to have_received(:add_team_member)
      end
    end

    context 'when not a member of the org' do
      before do
        allow(api).to receive(:organization_member?) { false }
      end
      it 'invites the user to the org and team' do
        action.execute
        expect(api).to have_received(:organization_member?).with('sgmap', 'ann-gh')
        expect(api).to have_received(:add_team_member).with(12, 'ann-gh')
      end
    end
  end
end
