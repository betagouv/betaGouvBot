# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::SortingHat do

  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:sorted)        { described_class.(members, today) }

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
