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
end
