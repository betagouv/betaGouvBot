# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Anticipator do
  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:days)          { 10 }
  let(:whenever)      { today + days }
  let(:notifications) { described_class.(members, [days], today) }

  context 'when member list is empty' do
    let(:members) { [] }

    it 'generates no notification' do
      expect(notifications).to eq({})
    end
  end

  context 'when one member has end date in the future' do
    let(:members) { [{ fullname: 'lbo', end: whenever.to_s }] }

    it "generates a notification" do
      expect(notifications).to match(days => [a_hash_including("fullname" => 'lbo')] )
    end
  end

  context 'when two members have an end date in the future' do
    let(:members) do
      [
        { fullname: 'lbo', end: whenever.to_s },
        { fullname: 'you', end: whenever.to_s }
      ]
    end

    it "generates a single notification" do
      expected = [a_hash_including("fullname" => 'lbo'), a_hash_including("fullname" => 'you')]
      expect(notifications).to match(days => expected)
    end
  end

  context 'when members have no end date' do
    let(:members) { [{ fullname: 'lbo' }, { fullname: 'you', end: '' }] }

    it 'generates no notifications' do
      expect(notifications).to be_empty
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
      expect(notifications).to be_empty
    end
  end

  context 'when hashes are stringified' do
    let(:members) { ['fullname' => 'lbo', 'end' => whenever.to_s] }

    it 'does its thing anyway' do
      expect(notifications).to match(days => [a_hash_including("fullname" => 'lbo')] )
    end
  end
end
