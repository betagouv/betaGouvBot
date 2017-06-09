# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountRequest do
  describe 'requesting email accounts' do
    context 'when a Slack user requests a beta.gouv.fr email' do
      let(:ann)      { 'ann' }
      let(:bob)      { 'bob' }
      let(:joe)      { 'joe' }

      let(:authors)  { [{ id: ann }, { id: bob }] }
      let(:fullname) { bob }
      let(:email)    { "#{fullname}@email.coop" }
      let(:password) { 'password' }

      before { allow(described_class).to receive(:client) }

      shared_examples 'sending notifications' do
        it 'notifies the backing address' do
          is_expected.to include be_a_kind_of(BetaGouvBot::MailAction)
            .and(have_attributes('subject' => 'Ton adresse @beta.gouv.fr'))
            .and(have_attributes('recipients' => [{ 'email' => 'bob@email.coop' }]))
        end
      end

      context 'with valid parameters' do
        subject { described_class.(authors, fullname, email, password) }

        it 'creates an email account' do
          is_expected.to include be_a_kind_of(BetaGouvBot::AccountAction)
            .and(have_attributes(name: 'bob'))
            .and(have_attributes(password: 'password'))
        end

        it 'creates a redirection' do
          is_expected.to include be_a_kind_of(BetaGouvBot::RedirectAction)
            .and(have_attributes(name: 'bob'))
            .and(have_attributes(redirect: 'bob@email.coop'))
        end

        it_behaves_like 'sending notifications'

        context 'with a starred address' do
          let(:email) { '*bob@email.coop' }

          it 'does not create a redirection' do
            is_expected.not_to include(be_a_kind_of(BetaGouvBot::RedirectAction))
          end

          it_behaves_like 'sending notifications'
        end

        context 'when a request is made by a non member' do
          let(:fullname) { 'joe' }

          it 'does not create and account' do
            is_expected.to be_empty
          end
        end
      end

      context 'with invalid parameters' do
        subject { -> { described_class.(authors, fullname, email, password) } }

        context 'with an invalid fullname' do
          let(:fullname) { 'bob69' }

          it { is_expected.to raise_error(described_class::InvalidNameError) }
        end

        context 'with an invalid email' do
          let(:email) { '#bob@email.coop' }

          it { is_expected.to raise_error(described_class::InvalidEmailError) }
        end
      end
    end
  end
end
