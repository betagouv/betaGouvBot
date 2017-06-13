# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::MailAction do
  describe 'sending email' do
    subject         { instance_spy('api') }

    let(:mail_hash) { { 'content' => 'whatever' } }
    let(:action)    { described_class.new(mail_hash) }
    let(:api)       { instance_double('api', new: subject) }

    before { allow(action).to receive(:api) { api } }

    it 'posts its body to the API' do
      action.execute
      is_expected.to have_received(:post).with(request_body: mail_hash)
    end
  end
end
