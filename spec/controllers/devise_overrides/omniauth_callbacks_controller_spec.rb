require 'rails_helper'

RSpec.describe 'OIDC OmniAuth Callbacks', type: :request do
  def set_oidc_config(email = 'test@example.com')
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new(
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

  describe '#openid_connect callback' do
    before do
      GlobalConfig.clear_cache
    end

    context 'when user already exists' do
      it 'signs in the existing user and redirects with sso_auth_token' do
        with_modified_env FRONTEND_URL: 'http://www.example.com' do
          create(:user, email: 'existing@example.com')
          set_oidc_config('existing@example.com')

          get '/omniauth/openid_connect/callback'

          expect(response).to redirect_to('http://www.example.com/auth/openid_connect/callback')
          follow_redirect!

          expect(response).to redirect_to(%r{/app/login\?email=.+&sso_auth_token=.+$})
        end
      end
    end

    context 'when user does not exist and signup is enabled' do
      it 'creates a new user and account' do
        with_modified_env ENABLE_ACCOUNT_SIGNUP: 'true', FRONTEND_URL: 'http://www.example.com' do
          set_oidc_config('newoidcuser@example.com')
          allow(Account::SignUpEmailValidationService).to receive(:new).and_return(
            instance_double(Account::SignUpEmailValidationService, perform: true)
          )

          expect {
            get '/omniauth/openid_connect/callback'
            follow_redirect!
          }.to change(User, :count).by(1)
        end
      end
    end

    context 'when user does not exist and signup is disabled' do
      it 'redirects to login page with no-account-found error' do
        with_modified_env ENABLE_ACCOUNT_SIGNUP: 'false', FRONTEND_URL: 'http://www.example.com' do
          set_oidc_config('newoidcuser@example.com')

          get '/omniauth/openid_connect/callback'

          expect(response).to redirect_to('http://www.example.com/auth/openid_connect/callback')
          follow_redirect!

          expect(response).to redirect_to(%r{/app/login\?error=no-account-found$})
        end
      end
    end
  end
end
