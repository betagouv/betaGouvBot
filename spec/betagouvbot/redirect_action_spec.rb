# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::RedirectAction do
  describe 'executing actions' do
    let(:ovh)       { instance_spy('ovh') }
    let(:api)       { instance_spy('api') }
    let(:action)    { described_class.new('ann', 'ann@gmail.com') }
    let(:endpoint)  { '/email/domain/beta.gouv.fr/redirection' }

    before do
      allow(action).to receive(:ovh) { ovh }
      allow(ovh).to receive(:new) { api }
      allow(api).to receive(:get) { [] }
    end

    it 'checks for existence of the redirection' do
      action.execute
      expect(api).to have_received(:get).with(endpoint, from: 'ann@beta.gouv.fr')
    end

    context 'when a redirection from that address exists' do
      before do
        allow(api).to receive(:get) { ['11413952074'] }
      end
      it 'updates the redirection with the new address' do
        update = "#{endpoint}/11413952074/changeRedirection"
        action.execute
        expect(api).to have_received(:get).with(endpoint, from: 'ann@beta.gouv.fr')
        expect(api).to have_received(:post).with(update, to: 'ann@gmail.com')
      end
    end

    context 'when no redirection exists' do
      it 'creates the redirection' do
        action.execute
        expect(api).to have_received(:get).with(endpoint, from: 'ann@beta.gouv.fr')
        expect(api).to have_received(:post)
          .with(endpoint,
                from: 'ann@beta.gouv.fr', to: 'ann@gmail.com', localCopy: 'false')
      end
    end
  end
end
