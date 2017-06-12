# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::BadgeRequest do
  describe 'requesting badges' do
    context 'when a Slack user requests a badge' do
      let(:ann)     { { id: 'ann', start: '2017-01-01', end: '2017-12-31' } }
      let(:bob)     { { id: 'bob', start: '2017-01-01', end: '2017-12-31' } }
      let(:authors) { [bob, ann] }

      let(:client) { instance_double('client') }

      before { allow(described_class).to receive(:client) { client } }

      describe 'selecting members' do
        before { allow(described_class).to receive(:request_badge) }

        it 'requests a badge for members who do not have one' do
          described_class.(authors, 'bob')
          is_expected.to have_received(:request_badge).with(bob).once
        end
      end

      describe 'sending email' do
        subject { described_class.(authors, 'ann') }

        it { is_expected.to include(a_kind_of(BetaGouvBot::MailAction)) }
        it { is_expected.to have(1).items }
      end
    end
  end
end
