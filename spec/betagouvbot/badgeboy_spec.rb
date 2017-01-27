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

      describe 'managing state' do
        let(:redis) { {} }

        before do
          allow(described_class).to receive(:request_badge)
          allow(described_class).to receive(:state_storage) { redis }
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

      describe 'sending email' do
        let(:mailer) { instance_spy('mailer') }
        let(:mail)   { {} }

        before do
          allow(described_class).to receive(:mailer) { mailer }
          allow(mailer).to receive(:format_email).and_return(mail)
        end

        it 'uses mailer to send email requesting badges' do
          described_class.request_badge(ann)
          expect(mailer).to have_received(:format_email).with(anything, anything, ann)
          expect(mailer).to have_received(:post).with(mail)
        end
      end
    end
  end
end
