# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::NotificationRule do
  describe '.horizons' do
    subject { described_class.horizons }

    it { is_expected.to match_array([21, 14, 1, -1]) }
  end

  describe '.all' do
    subject(:all) { described_class.all }

    it { is_expected.to match(duck_type(:each)) }
  end

  context 'three weeks before example' do
    subject(:rule) { described_class.all.first }

    it { expect(rule.horizon).to eq(21) }
    it { expect(rule.mail_file).to eq('data/mail_3w.md') }
    it { expect(rule.recipients).to include('{{author.id}}@beta.gouv.fr') }
  end
end
