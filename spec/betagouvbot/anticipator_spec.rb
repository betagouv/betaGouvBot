# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Anticipator do
  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:whenever)      { today + 10 }
  let(:notifications) { described_class.(members, today) }

  context 'when member list is empty' do
    let(:members) { [] }

    it 'generates no notification' do
      expect(notifications).to eq({})
    end
  end

  context 'when one member has end date in the future' do
    let(:members) { [{ fullname: 'lbo', end: whenever.to_s }] }

    it "generates a notification" do
      expect(notifications).to eq(10 => %w(lbo))
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
      expect(notifications).to eq(10 => %w(lbo you))
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
      expect(notifications).to eq(10 => %w(lbo))
    end
  end
end
