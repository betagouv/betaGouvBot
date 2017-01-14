# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  describe 'formatting emails' do
    let(:rules)    { {1 => "demain", 21 => "dans 3s"} }
    let(:parser)   { instance_spy('parser') }
    let(:template) { instance_spy('template') }

    before do
      allow(described_class).to receive(:template_factory) { parser }
      allow(parser).to receive(:parse) { template }
    end

    context "when a member has an end date in three weeks" do

      let(:author)   { {id: 'ann', fullname: 'Ann', end: (Date.today+10).iso8601} }
      let(:urgency)  { 21 }

      it 'formats email by parsing the appropriate template and passing in author' do
        described_class.body(urgency, author, rules)
        expect(parser).to have_received(:parse).with("dans 3s")
        expect(template).to have_received(:render).with("author" => author)
      end
    end
  end

  describe 'selecting recipients of emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, Date.today) }
    let(:recipient) { instance_spy('recipient') }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:recipient) { recipient }
      allow(described_class).to receive(:client) { client }
    end

    context "when a member has an end date in three weeks" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule)
        expect(recipient).to have_received(:new).with(email: 'ann@beta.gouv.fr')
      end
    end

    context "when a member has an end date soon" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+10).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule)
        expect(recipient).to have_received(:new).with(email: 'contact@beta.gouv.fr')
      end
    end

    context "when a member has an end date tomorrow" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+1).iso8601] }

      it 'sends an email directly to the author' do
        described_class.(schedule)
        expect(recipient).to have_received(:new).with(email: 'contact@beta.gouv.fr')
      end
    end
  end

  describe 'sending out emails' do
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, Date.today) }
    let(:client)    { instance_spy('client') }

    before do
      allow(described_class).to receive(:client) { client }
    end

    context "when one member has an end date in three weeks" do
      let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601] }

      it 'sends out one email' do
        described_class.(schedule)
        expect(client).to have_received(:post).once
      end
    end

    context "when two members have an end date in three weeks" do
      let(:authors)   { [{id: 'ann', fullname: 'Ann', end: (Date.today+21).iso8601}, {id: 'bob', fullname: 'Bob', end: (Date.today+21).iso8601}] }

      it 'sends out two emails' do
        described_class.(schedule)
        expect(client).to have_received(:post).twice
      end
    end

  end

end
