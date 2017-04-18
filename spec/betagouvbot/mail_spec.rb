# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mail do
  describe 'formatting emails' do
    let(:parser)   { instance_spy('parser') }
    let(:template) { instance_spy('template') }

    before do
      allow(described_class).to receive(:template_factory) { parser }
      allow(parser).to receive(:parse) { template }
    end

    context 'when a member has an end date in three weeks' do
      let(:author) { { id: 'ann', fullname: 'Ann', end: (Date.today + 10).iso8601 } }

      it 'formats email by parsing the appropriate template and passing in author' do
        described_class.render('dans 3s', 'author' => author)
        expect(parser).to have_received(:parse).with('dans 3s')
        expect(template).to have_received(:render).with('author' => author)
      end
    end
  end
end
