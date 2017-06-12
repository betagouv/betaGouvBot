# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  let(:horizons) { BetaGouvBot::NotificationRule.horizons }
  let(:schedule) { BetaGouvBot::Anticipator.(authors, horizons, Date.today) }

  before { allow(described_class).to receive(:email) }

  describe 'selecting recipients of emails' do
    before { allow(described_class).to receive(:rule) { rule } }

    let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }
    let(:rule)    { BetaGouvBot::NotificationRule.find(horizon: 21) }

    it 'sends an email directly to the author' do
      described_class.(schedule)
      expect(described_class).to have_received(:email)
        .with({ 'author' => authors.first }, rule)
    end
  end

  describe 'sending out emails' do
    context 'when one member has an end date' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends out one email' do
        described_class.(schedule)
        expect(described_class).to have_received(:email).once
      end
    end

    context 'when two members have an end date in three weeks' do
      let(:authors) do
        [
          { id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601 },
          { id: 'bob', fullname: 'Bob', end: (Date.today + 21).iso8601 }
        ]
      end

      it 'sends out two emails' do
        described_class.(schedule)
        expect(described_class).to have_received(:email).twice
      end
    end
  end
end
