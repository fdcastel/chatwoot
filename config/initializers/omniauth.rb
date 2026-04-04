# OmniAuth configuration
# Sets the full host URL for callbacks and proper redirect handling
OmniAuth.config.full_host = ENV.fetch('FRONTEND_URL', 'http://localhost:3000')

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV.fetch('GOOGLE_OAUTH_CLIENT_ID', nil), ENV.fetch('GOOGLE_OAUTH_CLIENT_SECRET', nil), {
    provider_ignores_state: true
  }

  # OIDC provider is always registered (like Google OAuth2) so OmniAuth routes exist.
  # The login button is only shown when OIDC_ISSUER is configured (see DashboardController#allowed_login_methods).
  oidc_issuer = ENV.fetch('OIDC_ISSUER', nil)
  provider :openid_connect,
           name: :openid_connect,
           issuer: oidc_issuer,
           scope: [:openid, :email, :profile],
           response_type: :code,
           discovery: oidc_issuer.present?,
           client_options: {
             identifier: ENV.fetch('OIDC_CLIENT_ID', nil),
             secret: ENV.fetch('OIDC_CLIENT_SECRET', nil),
             redirect_uri: "#{ENV.fetch('FRONTEND_URL', 'http://localhost:3000')}/omniauth/openid_connect/callback"
           }
end
