# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::BadgeRequest do
  describe 'requesting badges' do
    context 'when a member is working out of DINSIC offices' do
      let(:ann)     { { id: 'ann',
                        start: '2017-01-01',
                        end: '2017-12-31',
                        based: 'dinsic' }
      }
      let(:bob)     { { id: 'bob', start: '2017-01-01', end: '2017-12-31' } }
      let(:authors) { [bob, ann] }

      let(:redis)  { {} }
      let(:client) { instance_spy('client') }

      before do
        allow(described_class).to receive(:client) { client }
        allow(described_class).to receive(:state_storage) { redis }
      end

      describe 'selecting members' do
        before do
          allow(described_class).to receive(:request_badge)
        end

        it 'requests a badge for members who do not have one' do
          described_class.(authors)
          expect(described_class).to have_received(:request_badge).once
          expect(described_class).to have_received(:request_badge).with(ann)
        end
      end

      describe 'sending email' do
        it 'creates a mail action' do
          actions = described_class.request_badge(ann)
          expect(actions).to include(a_kind_of(BetaGouvBot::MailAction))
        end
      end

      describe 'managing state' do
        it 'requests a badge only once' do
          2.times { described_class.(authors).map(&:execute) }
          expect(client).to have_received(:post).once
        end

        it 'requests a new badge if dates change' do
          described_class.(authors).map(&:execute)
          ann[:end] = '2018-12-31'
          described_class.(authors).map(&:execute)
          expect(client).to have_received(:post).twice
        end
      end
    end
  end
end
