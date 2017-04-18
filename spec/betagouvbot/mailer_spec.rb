# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  Mail = BetaGouvBot::Mail
  let(:rules) { { 1 => { mail:  Mail.new('demain', nil,
                                         ['{{author.id}}@beta.gouv.fr'], []) },
                  14 => { mail: Mail.new('dans 2s', nil,
                                         ['{{author.id}}@beta.gouv.fr',
                                          'contact@beta.gouv.fr'], []) },
                  21 => { mail: Mail.new('dans 3s', nil,
                                         ['{{author.id}}@beta.gouv.fr'], []) } }
  }

  describe 'selecting recipients of emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, rules.keys, Date.today) }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:client) { client }
    end

    context 'when a member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule, rules)
        recipients = hash_including(to: ['email' => 'ann@beta.gouv.fr'])
        expected = hash_including(personalizations: array_including(recipients))
        expect(client).to have_received(:post).with(request_body: expected)
      end
    end

    context 'when a member has an end date in two weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 14).iso8601] }

      it 'sends an email to the author and contact' do
        described_class.(schedule, rules)
        recipients_list = [{ 'email' => 'ann@beta.gouv.fr' },
                           { 'email' => 'contact@beta.gouv.fr' }]
        recipients = hash_including(to: recipients_list)
        expected = hash_including(personalizations: array_including(recipients))
        expect(client).to have_received(:post).with(request_body: expected)
      end
    end
  end

  describe 'sending out emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, rules.keys, Date.today) }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:client) { client }
    end

    context 'when one member has an end date in three weeks' do
      let(:authors) { [id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601] }

      it 'sends out one email' do
        described_class.(schedule, rules)
        expect(client).to have_received(:post).once
      end
    end

    context 'when two members have an end date in three weeks' do
      let(:authors) { [{ id: 'ann', fullname: 'Ann', end: (Date.today + 21).iso8601 },
                       { id: 'bob', fullname: 'Bob', end: (Date.today + 21).iso8601 }]
      }

      it 'sends out two emails' do
        described_class.(schedule, rules)
        expect(client).to have_received(:post).twice
      end
    end
  end
end
