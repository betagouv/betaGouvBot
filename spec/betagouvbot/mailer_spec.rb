# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  describe 'content of emails' do
    let(:members) { %w(Ann Bob) }
    let(:urgency) { :tomorrow }

    subject(:content) { described_class.content(urgency, members).value }

    it { is_expected.to include('Les contrats de') }
    it { is_expected.to include('Ann') }
    it { is_expected.to include('Bob') }
    it { is_expected.to include('arrivent à échéance') }
    it { is_expected.to include('demain') }
  end

  describe 'sending out emails' do
    let(:authors)   { [id: 'ann', fullname: 'Ann', end: (Date.today+1).iso8601] }
    let(:schedule)  { BetaGouvBot::Anticipator.(authors, Date.today) }
    let(:client)    { instance_spy('client') }
    let(:recipient) { instance_spy('recipient') }

    before do
      allow(described_class).to receive(:recipient) { recipient }
      allow(described_class).to receive(:client) { client }
    end

    context "when it's 3 weeks before ending date" do
      it 'sends an email directly to the author' do
        described_class.(schedule)
        expect(recipient).to have_received(:new).with(email: 'contact@beta.gouv.fr')
      end
    end
  end
end
