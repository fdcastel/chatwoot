require 'rails_helper'

RSpec.describe DeviseOverrides::OmniauthCallbacksController, type: :controller do
  include Devise::Test::ControllerHelpers

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#openid_connect' do
    let(:oidc_auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'openid_connect',
        uid: 'oidc-uid-123',
        info: {
          email: email,
          name: 'OIDC User',
          email_verified: true
        },
        extra: {
          raw_info: {
            email_verified: true
          }
        }
      )
    end

    before do
      request.env['omniauth.auth'] = oidc_auth_hash
    end

    context 'when user already exists' do
      let(:email) { existing_user.email }
      let!(:existing_user) { create(:user) }

      it 'signs in the existing user and redirects with sso_auth_token' do
        get :openid_connect

        expect(response).to have_http_status(:redirect)
        redirect_uri = URI.parse(response.redirect_url)
        params = Rack::Utils.parse_query(redirect_uri.query)
        expect(redirect_uri.path).to eq('/app/login')
        expect(params['email']).to eq(existing_user.email)
        expect(params['sso_auth_token']).to be_present
      end
    end

    context 'when user does not exist and signup is enabled' do
      let(:email) { 'newoidcuser@example.com' }

      before do
        allow(GlobalConfigService).to receive(:account_signup_enabled?).and_return(true)
      end

      it 'creates a new user and account' do
        expect { get :openid_connect }.to change(User, :count).by(1)
      end
    end

    context 'when user does not exist and signup is disabled' do
      let(:email) { 'newoidcuser@example.com' }

      before do
        allow(GlobalConfigService).to receive(:account_signup_enabled?).and_return(false)
      end

      it 'redirects to login page with no-account-found error' do
        get :openid_connect

        expect(response).to have_http_status(:redirect)
        redirect_uri = URI.parse(response.redirect_url)
        params = Rack::Utils.parse_query(redirect_uri.query)
        expect(params['error']).to eq('no-account-found')
      end
    end
  end
end
