# Chatwoot — Custom Internal Fork

> **Internal use only.** This is a custom fork of the official [Chatwoot](https://github.com/chatwoot/chatwoot) project maintained for internal deployment purposes.

## Official Project

Refer to the [official repository](https://github.com/chatwoot/chatwoot) for general documentation, deployment guides, and community resources.

## About this fork

This fork is based on [Chatwoot v4.12.1](https://github.com/chatwoot/chatwoot/releases/tag/v4.12.1).

Each added feature is documented in the [`docs/`](docs/) folder:

| Feature | Document |
|---------|----------|
| Instance-wide OIDC SSO Login | [docs/FEATURE_OIDC_SSO_LOGIN.md](docs/FEATURE_OIDC_SSO_LOGIN.md) |

## Custom Docker Images

Custom Docker images are built automatically on every push to this branch and published to the [GitHub Container Registry](https://github.com/fdcastel?tab=packages) under the `fdcastel` namespace:

| Image | Pull command |
| ----- | ------------ |
| chatwoot | `docker pull ghcr.io/fdcastel/chatwoot` |

Images are tagged with the upstream release version (e.g. `v4.12.1`) and `latest`.
