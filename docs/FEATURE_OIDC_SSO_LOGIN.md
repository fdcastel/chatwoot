# Feature: Instance-Wide OIDC SSO Login

Adds OpenID Connect (OIDC) as a supported authentication method at the instance level. Operators can configure any OIDC-compliant identity provider (Keycloak, Auth0, Okta, Azure AD, Google Workspace, etc.) and expose a single-sign-on login button to all users.

## How it works

1. The server bootstraps the OIDC provider at startup using the environment variables below.
2. When a user clicks the **Sign in with SSO** button on the login page they are redirected to the identity provider's authorisation endpoint (`/auth/openid_connect`).
3. After successful authentication the identity provider redirects back to `/omniauth/openid_connect/callback`.
4. Chatwoot signs the user in (or creates a new account if `ENABLE_ACCOUNT_SIGNUP` allows it) and issues the usual token pair.
5. Users provisioned through OIDC (their `provider` column is set to `openid_connect`) **cannot log in with a password**. Attempting to do so returns an error directing them to use the SSO button.

## Environment Variables

### Required

| Variable | Description |
|----------|-------------|
| `OIDC_ISSUER` | The issuer URL of the OIDC provider (e.g. `https://accounts.google.com`). Its presence **activates** the OIDC integration. The provider's OIDC discovery document must be reachable at `<OIDC_ISSUER>/.well-known/openid-configuration`. |
| `OIDC_CLIENT_ID` | The client ID registered with the identity provider. |
| `OIDC_CLIENT_SECRET` | The client secret registered with the identity provider. |

### Optional / UI customisation

| Variable | Default | Description |
|----------|---------|-------------|
| `OIDC_DISPLAY_NAME` | `SSO` | The provider name shown on the login button (e.g. `Google Workspace`, `Okta`). |
| `OIDC_ICON_URL` | *(none)* | URL of the provider's logo shown on the login button. When omitted a generic lock icon is rendered. |

### Callback URL

Set the following redirect URI in your identity provider's application settings:

```
<FRONTEND_URL>/omniauth/openid_connect/callback
```

Where `FRONTEND_URL` is the value already configured in your Chatwoot environment.

## Super Admin toggle

The feature can be disabled at runtime without restarting the server via the **Super Admin → Installation Config** panel:

| Key | Default | Description |
|-----|---------|-------------|
| `ENABLE_OIDC_LOGIN` | `true` | When set to `false` the SSO button is hidden from the login page even if the provider is configured. Useful to temporarily disable the integration without removing the environment variables. |

## Files changed

| File | Change |
|------|--------|
| `Gemfile` | Added `omniauth_openid_connect` gem |
| `config/initializers/omniauth.rb` | Registers the OIDC provider with OmniAuth when `OIDC_ISSUER` is set |
| `app/controllers/devise_overrides/omniauth_callbacks_controller.rb` | Added `openid_connect` action delegating to `omniauth_success` |
| `app/controllers/devise_overrides/sessions_controller.rb` | Blocks password login for users provisioned via OIDC |
| `app/controllers/dashboard_controller.rb` | Adds `'oidc'` to `allowedLoginMethods` when the feature is enabled |
| `app/controllers/super_admin/app_configs_controller.rb` | Exposes `ENABLE_OIDC_LOGIN` in the Super Admin config page |
| `app/models/user.rb` | Adds `:openid_connect` to the list of accepted OmniAuth providers |
| `app/views/layouts/vueapp.html.erb` | Injects `oidcIssuer`, `oidcDisplayName`, and `oidcIconUrl` into `window.chatwootConfig` |
| `config/installation_config.yml` | Adds the `ENABLE_OIDC_LOGIN` installation config entry |
| `config/locales/en.yml` | Adds `errors.signin.use_oidc_login` backend error message |
| `app/javascript/v3/components/OidcLogin/Button.vue` | New OIDC login button component |
| `app/javascript/v3/views/login/Index.vue` | Renders the OIDC button when the feature is active |
| `app/javascript/dashboard/i18n/locale/en/login.json` | Adds `LOGIN.OIDC.BUTTON` i18n string |
