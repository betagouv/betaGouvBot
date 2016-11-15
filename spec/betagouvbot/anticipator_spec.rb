# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Anticipator do
  let(:yesterday)     { today - 1 }
  let(:today)         { Date.today }
  let(:tomorrow)      { today + 1 }
  let(:in_ten_days)   { today + 10 }
  let(:notifications) { described_class.(members, today) }

  context 'when member list is empty' do
    let(:members) { [] }

    it 'generates no notification' do
      expect(notifications).to eq({})
    end
  end

  context 'when one member has end date tomorrow' do
    let(:members) { [{ fullname: 'lbo', end: tomorrow.to_s }] }

    it "generates a 'tomorrow' notification" do
      expect(notifications).to eq(tomorrow: %w(lbo))
    end
  end

  context 'when two members have an end date tomorrow' do
    let(:members) do
      [
        { fullname: 'lbo', end: tomorrow.to_s },
        { fullname: 'you', end: tomorrow.to_s }
      ]
    end

    it "generates one 'tomorrow' notification" do
      expect(notifications).to eq(tomorrow: %w(lbo you))
    end
  end

  context 'when one member has end date in ten days' do
    let(:members) { [fullname: 'lbo', end: in_ten_days.to_s] }

    it "generates a 'soon' notification" do
      expect(notifications).to eq(soon: %w(lbo))
    end
  end

  context 'when members have end dates with both cases' do
    let(:members) do
      [
        { fullname: 'lbo', end: in_ten_days.to_s },
        { fullname: 'you', end: tomorrow.to_s }
      ]
    end

    it "generates one 'tomorrow' notification" do
      expect(notifications)
        .to(eq(tomorrow: %w(you), soon: %w(lbo)))
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
    let(:members) { ['fullname' => 'lbo', 'end' => tomorrow.to_s] }

    it 'does its thing anyway' do
      expect(notifications).to eq(tomorrow: %w(lbo))
    end
  end
end
