# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::BadgeRequest do
  describe 'requesting badges' do
    context 'when a Slack user requests a badge' do
      let(:ann)     { { id: 'ann', start: '2017-01-01', end: '2017-12-31' } }
      let(:bob)     { { id: 'bob', start: '2017-01-01', end: '2017-12-31' } }
      let(:authors) { [bob, ann] }

      let(:client) { instance_spy('client') }

      before do
        allow(described_class).to receive(:client) { client }
      end

      describe 'selecting members' do
        before do
          allow(described_class).to receive(:request_badge)
        end

        it 'requests a badge for members who do not have one' do
          described_class.(authors, 'bob')
          expect(described_class).to have_received(:request_badge).once
          expect(described_class).to have_received(:request_badge).with(bob)
        end
      end

      describe 'sending email' do
        it 'creates a mail action' do
          actions = described_class.(authors, 'ann')
          expect(actions).to have(1).items
          expect(actions).to include(a_kind_of(BetaGouvBot::MailAction))
        end
      end
    end
  end
end
