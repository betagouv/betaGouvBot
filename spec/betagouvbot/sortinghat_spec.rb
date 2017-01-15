# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::SortingHat do

  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:sorted)        { described_class.(members, today) }

  describe 'sorting members from alumni' do

    context 'when member list is empty' do
      let(:members) { [] }

      it 'sorts into two empty arrays' do
        expect(sorted).to eq({members: [], alumni: []})
      end
    end

    context 'when member list has both kinds' do
      let(:ann)		{ {id: 'ann', fullname: 'Ann', end: today.iso8601} }
      let(:bob)		{ {id: 'bob', fullname: 'Bob', end: yesterday.iso8601} }
      let(:members)   { [bob,ann] }

      it 'sorts by splitting just after current date' do
        expect(sorted).to match({members: [ann], alumni: [bob]})
      end
    end

  end

  describe 'getting subscription lists' do
    let(:ovh)      { instance_spy('ovh') }
    let(:api)      { instance_spy('api') }

    before do
      allow(described_class).to receive(:ovh) { ovh }
      allow(ovh).to receive(:new) { api }
      allow(api).to receive(:get)
    end

    it 'retrieves members from the "incubateur" list' do
      described_class.members
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:get).with("/email/domain/beta.gouv.fr/mailingList/incubateur/subscriber")
    end

    it 'retrieves alumni from the "alumni" list' do
      described_class.alumni
      expect(ovh).to have_received(:new)
      expect(api).to have_received(:get).with("/email/domain/beta.gouv.fr/mailingList/alumni/subscriber")
    end

  end

end
