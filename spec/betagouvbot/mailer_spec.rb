# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do

  let(:rules)    { {1 => "demain", 14 => "dans 2s", 21 => "dans 3s"} }

  describe 'formatting emails' do
    let(:parser)   { instance_spy('parser') }
    let(:template) { instance_spy('template') }

    before do
      allow(described_class).to receive(:template_factory) { parser }
      allow(parser).to receive(:parse) { template }
    end

    context "when a member has an end date in three weeks" do

      let(:author)   { {id: 'ann', fullname: 'Ann', end: (Date.today+10).iso8601} }

      it 'formats email by parsing the appropriate template and passing in author' do
        described_class.render("dans 3s", author)
        expect(parser).to have_received(:parse).with("dans 3s")
        expect(template).to have_received(:render).with("author" => author)
      end
    end
  end

  describe 'selecting recipients of emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, rules.keys, Date.today) }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:client) { client }
    end

    context "when a member has an end date in three weeks" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule,rules)
        recipients = hash_including("to" => ["email" => "ann@beta.gouv.fr"])
        expected = {request_body: hash_including("personalizations" => array_including(recipients))}
        expect(client).to have_received(:post).with(expected)
      end
    end

    context "when a member has an end date in two weeks" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+14).iso8601] }

      it 'sends an email to the author and contact' do
        described_class.(schedule,rules)
        recipients = hash_including("to" => [{"email" => "ann@beta.gouv.fr"}, {"email" => "contact@beta.gouv.fr"}])
        expected = {request_body: hash_including("personalizations" => array_including(recipients))}
        expect(client).to have_received(:post).with(expected)
      end
    end

  end

  describe 'sending out emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, rules.keys, Date.today) }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:client) { client }
    end

    context "when one member has an end date in three weeks" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601] }

      it 'sends out one email' do
        described_class.(schedule,rules)
        expect(client).to have_received(:post).once
      end
    end

    context "when two members have an end date in three weeks" do
      let(:authors)   { [{id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601}, {id: 'bob', fullname: 'Bob', end: (Date.today+21).iso8601}] }

      it 'sends out two emails' do
        described_class.(schedule,rules)
        expect(client).to have_received(:post).twice
      end
    end

  end

end
