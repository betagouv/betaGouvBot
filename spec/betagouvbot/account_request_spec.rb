# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountRequest do
  describe 'requesting email accounts' do
    context 'when a Slack user requests a beta.gouv.fr email' do
      let(:ann)     { { id: 'ann' } }
      let(:bob)     { { id: 'bob' } }
      let(:authors) { [bob, ann] }

      before { allow(described_class).to receive(:client) }

      context 'with valid parameters' do
        it 'creates an email account' do
          actions = described_class.(authors, 'bob bob@gmail.com password')
          matching = be_a_kind_of(BetaGouvBot::AccountAction)
                     .and have_attributes(name: 'bob')
                     .and have_attributes(password: 'password')
          expect(actions).to include(matching)
        end

        it 'creates a redirection' do
          actions = described_class.(authors, 'bob bob@gmail.com password')
          matching = be_a_kind_of(BetaGouvBot::RedirectAction)
                     .and have_attributes(name: 'bob')
                     .and have_attributes(redirect: 'bob@gmail.com')
          expect(actions).to include(matching)
        end

        it 'creates no redirection for a starred address' do
          actions = described_class.(authors, 'bob *bob@gmail.com password')
          matching = be_a_kind_of(BetaGouvBot::RedirectAction)
          expect(actions).not_to include(matching)
        end

        it 'notifies the backing address for a starred address' do
          actions = described_class.(authors, 'bob *bob@gmail.com password')
          match_recipient = array_including(a_hash_including('email' => 'bob@gmail.com'))
          matching = be_a_kind_of(BetaGouvBot::MailAction)
                     .and have_attributes(recipients: match_recipient)
          expect(actions).to include(matching)
        end

        it 'notifies the backing address' do
          actions = described_class.(authors, 'bob bob@gmail.com pass')
          match_recipient = array_including(a_hash_including('email' => 'bob@gmail.com'))
          matching = be_a_kind_of(BetaGouvBot::MailAction)
                     .and have_attributes(subject: 'Ton adresse @beta.gouv.fr')
                     .and have_attributes(recipients: match_recipient)
          expect(actions).to include(matching)
        end

        it 'creates accounts only for members' do
          actions = described_class.(authors, 'joe blah@blah.coop blah')
          expect(actions).to be_empty
        end
      end

      context 'with invalid parameters' do
        subject { -> { described_class.(authors, params) } }

        context 'with an invalid fullname' do
          let(:params) { 'bob69 bob@email.coop password' }

          it { is_expected.to raise_error(described_class::InvalidNameError) }
        end

        context 'with an invalid email' do
          let(:params) { 'bob #bob@email.coop password' }

          it { is_expected.to raise_error(described_class::InvalidEmailError) }
        end
      end
    end
  end
end
