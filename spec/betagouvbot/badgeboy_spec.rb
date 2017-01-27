# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::BadgeBoy do
  describe 'requesting badges' do
    context 'when a member is working out of DINSIC offices' do
      let(:ann)     { { id: 'ann',
                        start: '2017-01-01',
                        end: '2017-12-31',
                        based: 'dinsic' }
      }
      let(:bob)     { { id: 'bob', start: '2017-01-01', end: '2017-12-31' } }
      let(:authors) { [bob, ann] }
      let(:redis)   { instance_spy('redis') }

      before do
        allow(described_class).to receive(:request_badge)
        allow(described_class).to receive(:state_storage) { redis }
        allow(redis).to receive(:get).and_return(nil)
        allow(redis).to receive(:get).and_return('2017-01-01/2017-12-31')
        allow(redis).to receive(:set)
      end

      it 'requests a badge for new members' do
        described_class.(authors)
        expect(described_class).to have_received(:request_badge).once
        expect(described_class).to have_received(:request_badge).with(ann)
      end

      it 'requests a badge only once' do
        2.times { described_class.(authors) }
        expect(described_class).to have_received(:request_badge).once
        expect(described_class).to have_received(:request_badge).with(ann)
      end
    end
  end
end
