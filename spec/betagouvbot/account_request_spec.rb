# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::AccountRequest do
  subject(:account_request) { described_class.new }

  describe 'requesting email accounts' do
    context 'when a Slack user requests a beta.gouv.fr email' do
      subject { described_class.new(authors, fullname, email, password).() }

      let(:ann)      { 'ann' }
      let(:bob)      { 'bob' }
      let(:joe)      { 'joe' }
      let(:authors)  { [{ id: ann }, { id: bob }] }
      let(:fullname) { bob }
      let(:email)    { "#{fullname}@email.coop" }
      let(:password) { 'password' }

      shared_examples 'sending notifications' do
        it 'notifies the backing address' do
          is_expected.to include be_a_kind_of(BetaGouvBot::MailAction)
            .and(have_attributes('subject' => 'Ton adresse @beta.gouv.fr'))
            .and(have_attributes('recipients' => [{ 'email' => 'bob@email.coop' }]))
        end
      end

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

      context 'validations' do
        subject(:action) { described_class.new(authors, fullname, email, password) }

        let(:errors) { action.errors.full_messages }

        before { action.validate }

        context 'with valid params' do
          it { is_expected.to be_valid }
          it { expect(errors).to be_empty }
        end

        context 'with a missing fullname' do
          let(:fullname) { nil }

          it { is_expected.not_to be_valid }
          it { expect(errors).to include('Le format du nom doit être prenom.nom') }
        end

        context 'with an invalid fullname' do
          let(:fullname) { 'bob69' }

          it { is_expected.not_to be_valid }
          it { expect(errors).to include('Le format du nom doit être prenom.nom') }
        end

        context 'with a missing email' do
          let(:email) { nil }

          it { is_expected.not_to be_valid }
          it { expect(errors).to include("L'email doit être présent et être valide") }
        end

        context 'with an invalid email' do
          let(:email) { '#bob@email.coop' }

          it { is_expected.not_to be_valid }
          it { expect(errors).to include("L'email doit être présent et être valide") }
        end

        context 'with a missing password' do
          let(:password) { nil }

          it { is_expected.not_to be_valid }
          it { expect(errors).to include('Le mot de passe doit être présent') }
        end
      end

      context 'broadcasting' do
        subject(:action) { described_class.new(authors, fullname, email, password) }

        it { is_expected.to broadcast(:success, include(respond_to(:execute))) }
        it { is_expected.not_to broadcast(:not_found) }
        it { is_expected.not_to broadcast(:error) }

        context 'with invalid params' do
          let(:fullname) { nil }
          let(:errors)   { action.errors.full_messages }

          before { action.validate }

          it { is_expected.to broadcast(:error, errors) }
          it { is_expected.not_to broadcast(:success) }
          it { is_expected.not_to broadcast(:not_found) }
        end

        context 'when a request is made for a non member' do
          let(:fullname) { 'joe' }

          it { is_expected.to broadcast(:not_found) }
          it { is_expected.not_to broadcast(:success) }
          it { is_expected.not_to broadcast(:error) }
        end
      end
    end
  end
end
