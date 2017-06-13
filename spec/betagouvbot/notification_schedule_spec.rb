# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::NotificationSchedule do
  subject { described_class.(members, [today, whenever]) }

  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:whenever)      { today + 10 }

  context 'when member list is empty' do
    let(:members) { [] }

    it 'generates no notification' do
      is_expected.to eq([])
    end
  end

  context 'when one member has end date in the future' do
    let(:members) { [{ fullname: 'lbo', end: whenever.to_s }] }

    it 'generates a notification' do
      expected = [{ term: 10, who: a_hash_including(fullname: 'lbo') }]
      is_expected.to match(expected)
    end
  end

  context 'when two members have an end date in the future' do
    let(:members) do
      [
        { fullname: 'lbo', end: whenever.to_s },
        { fullname: 'you', end: whenever.to_s }
      ]
    end

    it 'generates a single notification' do
      expected = [{ term: 10, who: a_hash_including(fullname: 'lbo') },
                  { term: 10, who: a_hash_including(fullname: 'you') }]
      is_expected.to match(expected)
    end
  end

  context 'when members have no end date' do
    let(:members) { [{ fullname: 'lbo' }, { fullname: 'you', end: '' }] }

    it 'generates no notifications' do
      is_expected.to be_empty
    end
  end

  context 'when members have end date already past' do
    let(:members) do
      [
        { fullname: 'lbo', end: yesterday.to_s },
        { fullname: 'you', end: '' }
      ]
    end

    it 'generates no notifications' do
      is_expected.to be_empty
    end
  end
end
