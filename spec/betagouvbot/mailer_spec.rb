# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  let(:in_3w) do
    instance_double(
      'mail',
      format: { personalizations: [to: ['email' => 'ann@email.coop']] }
    )
  end

  let(:in_2w) do
    instance_double(
      'mail',
      format: {
        personalizations: [
          to: [{ 'email' => 'ann@email.coop' }, { 'email' => 'hi@email.coop' }]
        ]
      }
    )
  end

  let(:rules) do
    {
      1  => { mail: instance_double('mail') },
      14 => { mail: in_2w },
      21 => { mail: in_3w }
    }
  end

  let(:schedule) { BetaGouvBot::Anticipator.(authors, rules.keys, Date.today) }

  before { allow(described_class).to receive(:post) }

  describe 'selecting recipients of emails' do
    context 'when a member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule, rules).map(&:execute)
        expect(described_class).to have_received(:post)
          .with(request_body: in_3w.format)
      end
    end

    context 'when a member has an end date in two weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 14).iso8601] }

      it 'sends an email to the author and contact' do
        described_class.(schedule, rules).map(&:execute)
        expect(described_class).to have_received(:post)
          .with(request_body: in_2w.format)
      end
    end
  end

  describe 'sending out emails' do
    context 'when one member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends out one email' do
        described_class.(schedule, rules).map(&:execute)
        expect(described_class).to have_received(:post).once
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
        described_class.(schedule, rules).map(&:execute)
        expect(described_class).to have_received(:post).twice
      end
    end
  end
end
