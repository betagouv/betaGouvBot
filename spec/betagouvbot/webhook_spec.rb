# encoding: utf-8
# frozen_string_literal: true

RSpec.describe BetaGouvBot::Webhook do
  let(:user_name)    { 'bob' }
  let(:token)        { 'asdf1234' }
  let(:valid_params) { base_params.merge(text: text) }

  before do
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

    before do
      allow(ENV).to receive(:[]).with('COMPTE_TOKEN') { token }
      stub_request(:any, /api.ovh.com/).to_return(body: [].to_json)
      stub_request(:post, /api.sendgrid.com/)
    end

    context 'with valid params' do
      before do
        stub_request(:post, callback).with(body: /demande de @bob/)
        stub_request(:post, callback).with(body: /OK/)
        post('/compte', valid_params)
      end

      it { expect(last_response).to be_ok }
      it { expect(last_response.body).to be_empty }

      it 'broadcasts acknowledge' do
        expect(a_request(:post, callback).with(body: /demande de @bob/))
          .to have_been_made
      end

      it 'broadcasts success' do
        expect(a_request(:post, callback).with(body: /OK/))
          .to have_been_made
      end
    end

    context 'with missing params' do
      context "with 'response_url' missing" do
        before do
          stub_request(:post, callback).with(body: { text: /response_url/ })
          post('/compte', valid_params.merge(response_url: ''))
        end

        it { expect(last_response).to be_ok }
        it { expect(last_response.body).to include('code') }
        it { expect(last_response.body).to include('400') }
        it { expect(last_response.body).to include('errors') }
        it { expect(last_response.body).to match(/response_url/) }

        it 'does not broadcast error' do
          expect(a_request(:post, callback).with(body: { text: /response_url/ }))
            .not_to have_been_made
        end
      end

      context "with 'user_name' missing" do
        before do
          stub_request(:post, callback).with(body: { text: /user_name/ })
          post('/compte', valid_params.merge(user_name: ''))
        end

        it { expect(last_response).to be_ok }
        it { expect(last_response.body).to include('code') }
        it { expect(last_response.body).to include('400') }
        it { expect(last_response.body).to include('errors') }
        it { expect(last_response.body).to match(/user_name/) }

        it 'broadcasts error' do
          expect(a_request(:post, callback).with(body: { text: /user_name/ }))
            .to have_been_made
        end
      end

      context "with 'token' missing" do
        before do
          stub_request(:post, callback).with(body: { text: /token/ })
          post('/compte', base_params.merge(token: ''))
        end

        it { expect(last_response).to be_ok }
        it { expect(last_response.body).to include('code') }
        it { expect(last_response.body).to include('400') }
        it { expect(last_response.body).to include('errors') }
        it { expect(last_response.body).to match(/token/) }

        it 'broadcasts error' do
          expect(a_request(:post, callback).with(body: { text: /token/ }))
            .to have_been_made
        end
      end
    end

    context "with invalid 'token'" do
      before do
        stub_request(:post, callback).with(body: { text: /token/ })
        post('/compte', valid_params.merge(token: token.reverse))
      end

      it { expect(last_response).to be_ok }
      it { expect(last_response.body).to include('code') }
      it { expect(last_response.body).to include('401') }
      it { expect(last_response.body).to include('errors') }
      it { expect(last_response.body).to match(/token/) }

      it 'broadcasts error' do
        expect(a_request(:post, callback).with(body: { text: /token/ }))
          .to have_been_made
      end
    end

    context "with 'text' missing" do
      before do
        stub_request(:post, callback).with(body: { text: %r{/compte} })
        post('/compte', valid_params.merge(text: ''))
      end

      it { expect(last_response).to be_ok }
      it { expect(last_response.body).to include('code') }
      it { expect(last_response.body).to include('422') }
      it { expect(last_response.body).to include('errors') }
      it { expect(last_response.body).to match(%r{/compte}) }

      it 'broadcasts error' do
        expect(a_request(:post, callback).with(body: { text: %r{/compte} }))
          .to have_been_made
      end
    end

    context "with 'text' invalid" do
      before do
        stub_request(:post, callback).with(body: /demande de @bob/)
        stub_request(:post, callback).with(body: { text: /erreur/ })
        post('/compte', valid_params.merge(text: 'bob69 #bob69'))
      end

      it { expect(last_response).to be_ok }
      it { expect(last_response.body).to include('code') }
      it { expect(last_response.body).to include('422') }
      it { expect(last_response.body).to include('errors') }
      it { expect(last_response.body).to match(/nom/) }
      it { expect(last_response.body).to match(/email/) }
      it { expect(last_response.body).to match(/mot de passe/) }

      it 'broadcasts acknowledge' do
        expect(a_request(:post, callback).with(body: /demande de @bob/))
          .to have_been_made
      end

      it 'broadcasts error' do
        expect(a_request(:post, callback).with(body: { text: /erreur/ }))
          .to have_been_made
      end
    end

    context 'not found' do
      before do
        stub_request(:post, callback).with(body: /demande de @bob/)
        stub_request(:post, callback).with(body: { text: /erreur/ })
        post('/compte', valid_params.merge(text: text.gsub('bob', 'joe')))
      end

      it { expect(last_response).to be_ok }
      it { expect(last_response.body).to include('code') }
      it { expect(last_response.body).to include('404') }
      it { expect(last_response.body).to include('errors') }
      it { expect(last_response.body).to match(/je ne vois pas de qui tu veux parler/) }

      it 'broadcasts acknowledge' do
        expect(a_request(:post, callback).with(body: /demande de @bob/))
          .to have_been_made
      end

      it 'broadcasts error' do
        expect(a_request(:post, callback).with(body: { text: /erreur/ }))
          .to have_been_made
      end
    end
  end
end
