# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountAction do
  describe 'executing actions' do
    subject         { instance_spy('api') }

    let(:ovh)       { instance_double('ovh', new: subject) }
    let(:action)    { described_class.new('ann', 'pwd') }
    let(:endpoint)  { described_class::ENDPOINT }

    before { allow(action).to receive(:ovh) { ovh } }

    it 'checks for existence of the account' do
      action.execute
      is_expected.to have_received(:get).with(endpoint, accountName: 'ann')
    end

    context 'when an account of that name exists' do
      before { allow(action).to receive(:existing) { ['ann'] } }

      it 'leaves the account alone' do
        action.execute
        is_expected.not_to have_received(:post)
      end
    end

    context 'when no account of that name exists' do
      before { allow(action).to receive(:existing) { [] } }

      it 'creates the account with initial password' do
        action.execute
        is_expected.to have_received(:post)
          .with(endpoint, accountName: 'ann', password: 'pwd')
      end
    end
  end
end
