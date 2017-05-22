# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::RedirectAction do
  describe 'executing actions' do
    subject         { instance_spy('api') }

    let(:ovh)       { instance_double('ovh', new: subject) }
    let(:action)    { described_class.new('ann', 'ann@gmail.com') }
    let(:endpoint)  { described_class::ENDPOINT }

    before { allow(action).to receive(:ovh) { ovh } }

    it 'checks for existence of the redirection' do
      action.execute
      is_expected.to have_received(:get).with(endpoint, from: 'ann@beta.gouv.fr')
    end

    context 'when a redirection from that address exists' do
      before { allow(action).to receive(:redirections) { ['11413952074'] } }

      it 'updates the redirection with the new address' do
        update = "#{endpoint}/11413952074/changeRedirection"
        action.execute
        is_expected.to have_received(:post).with(update, to: 'ann@gmail.com')
      end
    end

    context "when redirection doesn't exist" do
      before { allow(action).to receive(:redirections) { [] } }

      it 'creates the redirection' do
        action.execute
        is_expected.to have_received(:post).with(
          endpoint,
          from: 'ann@beta.gouv.fr',
          to: 'ann@gmail.com',
          localCopy: 'false'
        )
      end
    end
  end
end
