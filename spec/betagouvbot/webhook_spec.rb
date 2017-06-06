# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Webhook do
  let(:user_name) { 'bob' }
  let(:token)     { 'asdf1234' }

  before do
    stub_request(:any, 'https://beta.gouv.fr/api/v1.3/authors.json')
      .to_return(
        headers: { 'content-type' => 'application/json; charset=utf-8' },
        body: [id: user_name].to_json
      )
  end

  describe 'GET /actions' do
    before do
      allow(ENV).to receive(:[])
      allow(ENV).to receive(:[]).with('apiKey') { token }
      allow(ENV).to receive(:[]).with('consumerKey') { token }
      stub_request(:any, /api.ovh.com/).to_return(body: [].to_json)
    end

    it { expect(get('/actions')).to be_ok }
  end

  describe 'POST /compte' do
    let(:callback)     { 'https://bob.coop' }
    let(:text)         { "#{user_name} #{user_name}@email.coop password" }
    let(:base_params)  { { response_url: callback, user_name: user_name, token: token } }
    let(:valid_params) { base_params.merge(text: text) }

    before { stub_request(:any, callback) }

    it { expect(post('/compte')).not_to be_ok }
    it { expect(post('/compte', valid_params)).to be_ok }
  end
end
