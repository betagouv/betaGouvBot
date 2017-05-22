# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::SortingHat do
  let(:yesterday) { today - 1 }
  let(:today)     { Date.today }

  PREFIX = '/email/domain/beta.gouv.fr/mailingList'

  describe 'sorting members from alumni' do
    subject { described_class.sort(members, today) }

    context 'when member list is empty' do
      let(:members) { [] }

      it { is_expected.to eq(members: [], alumni: []) }
    end

    context 'when member list has both kinds' do
      let(:ann)     { { id: 'ann', fullname: 'Ann', end: today.iso8601 } }
      let(:bob)     { { id: 'bob', fullname: 'Bob', end: yesterday.iso8601 } }
      let(:members) { [bob, ann] }

      it { is_expected.to match(members: [ann], alumni: [bob]) }
    end

    context 'when member list has people without an end date' do
      let(:ann)     { { id: 'ann', fullname: 'Ann', end: today.iso8601 } }
      let(:err1)    { { id: 'err1', fullname: 'Err' } }
      let(:err2)    { { id: 'err2', fullname: 'Err', end: '' } }
      let(:members) { [ann, err1, err2] }

      it { is_expected.to match(members: [ann, err1, err2], alumni: []) }
    end
  end

  describe 'subscribing and unsubscribing emails' do
    subject   { instance_spy('api') }

    let(:ovh) { instance_double('ovh', new: subject) }

    before { allow(described_class).to receive(:ovh) { ovh } }

    it 'uses the API to unsubscribe an email' do
      described_class.unsubscribe('listname', 'bob@beta.gouv.fr').execute
      endpoint = "#{PREFIX}/listname/subscriber/bob@beta.gouv.fr"
      is_expected.to have_received(:delete).with(endpoint)
    end

    it 'uses the API to subscribe an email' do
      described_class.subscribe('listname', 'ann@beta.gouv.fr').execute
      endpoint = "#{PREFIX}/listname/subscriber"
      is_expected.to have_received(:post).with(endpoint, email: 'ann@beta.gouv.fr')
    end
  end

  describe 'getting subscription lists' do
    subject   { instance_spy('api') }

    let(:ovh) { instance_double('ovh', new: subject) }

    before { allow(described_class).to receive(:ovh) { ovh } }

    it 'retrieves members from the "incubateur" list' do
      described_class.members
      endpoint = "#{PREFIX}/incubateur/subscriber"
      is_expected.to have_received(:get).with(endpoint)
    end

    it 'retrieves alumni from the "alumni" list' do
      described_class.alumni
      endpoint = "#{PREFIX}/alumni/subscriber"
      is_expected.to have_received(:get).with(endpoint)
    end
  end

  describe 'reconciling subscription lists' do
    let(:current)  { ['someoneelse@gmail.com', 'ann@beta.gouv.fr'] }
    let(:computed) { [{ id: 'bob', fullname: 'Bob', end: today.iso8601 }] }

    let(:all) do
      [
        { id: 'ann', fullname: 'Ann', end: today.iso8601 },
        { id: 'bob', fullname: 'Bob', end: today.iso8601 }
      ]
    end

    before do
      allow(described_class).to receive(:unsubscribe)
      allow(described_class).to receive(:subscribe)
    end

    it 'subscribes members who should be on the list' do
      described_class.reconcile(all, current, computed, 'listname')
      expect(described_class).to have_received(:subscribe)
        .with('listname', 'bob@beta.gouv.fr')
        .once
    end

    it 'unsubscribes those who should not be on the list' do
      described_class.reconcile(all, current, computed, 'listname')
      expect(described_class).to have_received(:unsubscribe)
        .with('listname', 'ann@beta.gouv.fr')
        .once
    end
  end
end
