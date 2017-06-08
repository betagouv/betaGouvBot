# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Mail do
  describe 'formatting emails' do
    let(:template_builder) { class_double('Liquid::Template', parse: template) }
    let(:template)         { instance_spy('template') }
    let(:document_builder) { class_double('Kramdown::Document', new: document) }
    let(:document)         { instance_spy('document') }

    let(:mail) { described_class.new('dans 3s', nil, [], nil) }

    before do
      allow(mail).to receive(:template_builder) { template_builder }
      allow(mail).to receive(:document_builder) { document_builder }
    end

    context 'when a member has an end date in three weeks' do
      let(:author) { { id: 'ann', fullname: 'Ann', end: (Date.today + 10).iso8601 } }

      before { mail.format('author' => author) }

      it { expect(template_builder).to have_received(:parse).with('dans 3s') }
      it { expect(template).to have_received(:render).with('author' => author).thrice }
      it { expect(document).to have_received(:to_html) }
    end
  end
end
