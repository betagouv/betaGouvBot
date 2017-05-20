# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::SortingHat do
  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }

  PREFIX = '/email/domain/beta.gouv.fr/mailingList'

  describe 'sorting members from alumni' do
    let(:sorted) { described_class.sort(members, today) }

    context 'when member list is empty' do
      let(:members) { [] }

      it 'sorts into two empty arrays' do
        expect(sorted).to eq(members: [], alumni: [])
      end
    end

    context 'when member list has both kinds' do
      let(:ann)     { { id: 'ann', fullname: 'Ann', end: today.iso8601 } }
      let(:bob)     { { id: 'bob', fullname: 'Bob', end: yesterday.iso8601 } }
      let(:members) { [bob, ann] }

      it 'sorts by splitting just after current date' do
        expect(sorted).to match(members: [ann], alumni: [bob])
      end
    end

    context 'when member list has people without an end date' do
      let(:ann)   { { id: 'ann', fullname: 'Ann', end: today.iso8601 } }
      let(:err1)  { { id: 'err1', fullname: 'Err' } }
      let(:err2)  { { id: 'err2', fullname: 'Err', end: '' } }
      let(:members)   { [ann, err1, err2] }

      it 'sorts by splitting just after current date' do
        expect(sorted).to match(members: [ann, err1, err2], alumni: [])
      end
    end
  end

  describe 'subscribing and unsubscribing emails' do
    let(:ovh) { instance_spy('ovh') }
    let(:api) { instance_spy('api') }

    before do
      allow(described_class).to receive(:ovh) { ovh }
      allow(ovh).to receive(:new) { api }
      allow(api).to receive(:post)
      allow(api).to receive(:delete)
    end

    it 'uses the API to unsubscribe an email' do
      (described_class.unsubscribe 'listname', 'bob@beta.gouv.fr').execute
      endpoint = "#{PREFIX}/listname/subscriber/bob@beta.gouv.fr"
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:delete).with(endpoint)
    end

    it 'uses the API to subscribe an email' do
      (described_class.subscribe 'listname', 'ann@beta.gouv.fr').execute
      endpoint = "#{PREFIX}/listname/subscriber"
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:post).with(endpoint, email: 'ann@beta.gouv.fr')
    end
  end

  describe 'getting subscription lists' do
    let(:ovh) { instance_spy('ovh') }
    let(:api) { instance_spy('api') }

    before do
      allow(described_class).to receive(:ovh) { ovh }
      allow(ovh).to receive(:new) { api }
      allow(api).to receive(:get)
    end

    it 'retrieves members from the "incubateur" list' do
      described_class.members
      endpoint = "#{PREFIX}/incubateur/subscriber"
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:get).with(endpoint)
    end

    it 'retrieves alumni from the "alumni" list' do
      described_class.alumni
      endpoint = "#{PREFIX}/alumni/subscriber"
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:get).with(endpoint)
    end
  end

  describe 'reconciling subscription lists' do
    let(:all) { [{ id: 'ann', fullname: 'Ann', end: today.iso8601 },
                 { id: 'bob', fullname: 'Bob', end: today.iso8601 }]
    }
    let(:current)  { ['someoneelse@gmail.com', 'ann@beta.gouv.fr'] }
    let(:computed) { [{ id: 'bob', fullname: 'Bob', end: today.iso8601 }] }

    before do
      allow(described_class).to receive(:unsubscribe)
      allow(described_class).to receive(:subscribe)
    end

    it 'subscribes members who should be on the list' do
      actions = described_class.reconcile(all, current, computed, 'listname')
      expect(described_class).to have_received(:unsubscribe).once
      expect(described_class).to have_received(:unsubscribe)
        .with('listname', 'ann@beta.gouv.fr')
      notifs = actions.select { |action| action.instance_of? BetaGouvBot::MailAction }
      expect(notifs.length).to equal(2)
    end

    it 'unsubscribes those who should not' do
      actions = described_class.reconcile(all, current, computed, 'listname')
      expect(described_class).to have_received(:subscribe).once
      expect(described_class).to have_received(:subscribe)
        .with('listname', 'bob@beta.gouv.fr')
      notifs = actions.select { |action| action.instance_of? BetaGouvBot::MailAction }
      expect(notifs.length).to equal(2)
    end
  end
end
