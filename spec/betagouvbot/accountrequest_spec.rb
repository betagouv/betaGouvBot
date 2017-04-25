# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountRequest do
  describe 'requesting email accounts' do
    context 'when a Slack user requests a beta.gouv.fr email' do
      let(:ann)     { { id: 'ann' } }
      let(:bob)     { { id: 'bob' } }
      let(:authors) { [bob, ann] }

      before do
        allow(described_class).to receive(:client)
      end

      it 'creates an email account' do
        actions = described_class.(authors, 'bob bob@gmail.com')
        matching = be_a_kind_of(BetaGouvBot::AccountAction)
                   .and have_attributes(name: 'bob')
                   .and have_attributes(redirect: 'bob@gmail.com')
        expect(actions).to include(matching)
      end

      it 'notifies the backing address' do
        actions = described_class.(authors, 'bob bob@gmail.com')
        match_recipient = array_including(a_hash_including('email' => 'bob@gmail.com'))
        matching = be_a_kind_of(BetaGouvBot::MailAction)
                   .and have_attributes(subject: 'Création de compte beta.gouv.fr')
                   .and have_attributes(recipients: match_recipient)
        expect(actions).to include(matching)
      end

      it 'creates accounts only for members' do
        actions = described_class.(authors, 'joe')
        expect(actions).to be_empty
      end
    end
  end
end
