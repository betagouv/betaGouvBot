# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountAction do
  describe 'executing actions' do
    let(:ovh)       { instance_spy('ovh') }
    let(:api)       { instance_spy('api') }
    let(:action)    { described_class.new('ann', 'pwd') }
    let(:endpoint)  { '/email/domain/beta.gouv.fr/account' }

    before do
      allow(action).to receive(:ovh) { ovh }
      allow(ovh).to receive(:new) { api }
      allow(api).to receive(:get) { [] }
    end

    it 'checks for existence of the account' do
      action.execute
      expect(api).to have_received(:get).with(endpoint, accountName: 'ann')
    end

    context 'when an account of that name exists' do
      before do
        allow(api).to receive(:get) { ['ann'] }
      end
      it 'leaves the account alone' do
        action.execute
        expect(api).to have_received(:get).with(endpoint, accountName: 'ann')
        expect(api).not_to have_received(:post)
      end
    end

    context 'when no account of that name exists' do
      it 'creates the account with initial password' do
        action.execute
        expect(api).to have_received(:get).with(endpoint, accountName: 'ann')
        expect(api).to have_received(:post)
          .with(endpoint, accountName: 'ann', password: 'pwd')
      end
    end
  end
end
