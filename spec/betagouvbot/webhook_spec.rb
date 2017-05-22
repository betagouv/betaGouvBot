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

    before do
      allow(ENV).to receive(:[]).with('COMPTE_TOKEN') { token }
      stub_request(:any, /api.ovh.com/).to_return(body: [].to_json)
      stub_request(:post, /api.sendgrid.com/)
      stub_request(:post, callback)
    end

    context 'with missing params' do
      context "with 'response_url' missing" do
        before do
          stub_request(:post, callback).with(body: { text: /response_url/ })
          post('/compte', valid_params.merge(response_url: nil))
        end

        it { expect(last_response).not_to be_ok }
        it { expect(last_response.status).to eq(400) }
        it { expect(last_response.body).to include('errors') }
        it { expect(last_response.body).to match(/response_url/) }

        it 'does not publish error' do
          expect(a_request(:post, callback).with(body: { text: /response_url/ }))
            .not_to have_been_made
        end
      end

      %w[user_name token text].each do |param|
        context "with '#{param}' missing" do
          before do
            stub_request(:post, callback).with(body: { text: /#{param}/ })
            post('/compte', valid_params.merge("#{param}": nil))
          end

          it { expect(last_response).not_to be_ok }
          it { expect(last_response.status).to eq(400) }
          it { expect(last_response.body).to include('errors') }
          it { expect(last_response.body).to match(/#{param}/) }

          it 'publishes error' do
            expect(a_request(:post, callback).with(body: { text: /#{param}/ }))
              .to have_been_made
          end
        end
      end
    end

    context "with invalid 'token'" do
      before do
        stub_request(:post, callback).with(body: { text: /token/ })
        post('/compte', valid_params.merge(token: token.reverse))
      end

      it { expect(last_response).not_to be_ok }
      it { expect(last_response.status).to eq(401) }
      it { expect(last_response.body).to include('errors') }
      it { expect(last_response.body).to match(/token/) }

      it 'publishes error' do
        expect(a_request(:post, callback).with(body: { text: /token/ }))
          .to have_been_made
      end
    end

    context "with empty 'text'" do
      before do
        stub_request(:post, callback).with(body: /À la demande de @bob/)
        post('/compte', valid_params.merge(text: ''))
      end

      it { expect(request_account).not_to be_ok }
      it { expect(request_account.status).to eq(422) }
      it { expect(request_account.body).not_to include('errors') }
      # it { expect(last_response.body).to match(/token/) }
    end

    # it { expect(post('/compte', empty_params)).not_to be_ok }
    # it { expect(post('/compte', valid_params)).to be_ok }
    #
    # context 'helpers' do
    #   describe '#publish_error' do
    #     let(:publish_message) { hola }
    #   end
    # end
  end
end
