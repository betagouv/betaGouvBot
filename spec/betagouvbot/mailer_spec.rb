# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mailer do
  let(:urgency) { :tomorrow }
  let(:members) { %w(Ann Bob) }

  describe '.content' do
    subject(:content) { described_class.content(urgency, members).value }

    it { is_expected.to include('Les contrats de') }
    it { is_expected.to include('Ann') }
    it { is_expected.to include('Bob') }
    it { is_expected.to include('arrivent à échéance') }
    it { is_expected.to include('demain') }
  end
end
