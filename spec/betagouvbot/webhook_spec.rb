# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Webhook do
  let(:user_name)    { 'bob' }
  let(:token)        { 'asdf1234' }
  let(:valid_params) { base_params.merge(text: text) }

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('apiKey') { token }
    allow(ENV).to receive(:[]).with('consumerKey') { token }
    stub_request(:any, 'https://beta.gouv.fr/api/v1.3/authors.json')
      .to_return(
        headers: { 'content-type' => 'application/json; charset=utf-8' },
        body: [id: user_name].to_json
      )
  end

  describe 'GET /actions' do
    before { stub_request(:get, /api.ovh.com/).to_return(body: [].to_json) }

    it { expect(get('/actions')).to be_ok }
  end

  describe 'POST /badge' do
    before do
      allow(ENV).to receive(:[]).with('BADGE_TOKEN') { token }
      stub_request(:post, /api.sendgrid.com/)
    end

    let(:text)         { user_name }
    let(:base_params)  { { token: token } }

    it { expect(post('/badge', valid_params)).to be_ok }
  end

  describe 'POST /compte' do
    let(:callback)     { 'https://bob.coop' }
    let(:text)         { "#{user_name} #{user_name}@email.coop password" }
    let(:base_params)  { { response_url: callback, user_name: user_name, token: token } }
    let(:empty_params) { { response_url: callback, user_name: user_name } }
    let(:valid_params) { empty_params.merge(text: text) }

    before do
      allow(ENV).to receive(:[]).with('COMPTE_TOKEN') { token }
      stub_request(:any, /api.ovh.com/).to_return(body: [].to_json)
      stub_request(:post, /api.sendgrid.com/)
      stub_request(:post, callback)
    end

    it { expect(post('/compte')).not_to be_ok }
    it { expect(post('/compte', empty_params)).not_to be_ok }
    it { expect(post('/compte', valid_params)).to be_ok }
  end
end
