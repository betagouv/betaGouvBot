# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::SortingHat do

  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:tomorrow)      { today + 1 }
  let(:sorted)        { described_class.(members, today) }

  context 'when member list is empty' do
    let(:members) { [] }

    it 'sorts into two empty arrays' do
      expect(sorted).to eq({members: [], alumni: []})
    end
  end

end
