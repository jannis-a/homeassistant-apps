# homeassistant-apps

Home Assistant apps, published as signed images on ghcr.io.

## Apps

| App | Description | Upstream | License |
|---|---|---|---|
| [Grafana Alloy](alloy) | Metrics of Home Assistant, the host and all containers via Prometheus remote write, the host's journal via Loki push, without gaps during outages | [Grafana Alloy](https://github.com/grafana/alloy) | Apache-2.0 |

## Usage

[![Add the repository to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fjannis-a%2Fhomeassistant-apps)

Or add `https://github.com/jannis-a/homeassistant-apps` under Settings →
Apps → App store → ⋮ → Repositories. Each app's `DOCS.md` covers
its setup and options.

## Releases

Every directory with a `config.yaml` is an app. Every version in its
`config.yaml` on `main` is published as signed images for its architectures
to `ghcr.io/jannis-a/ha-app-<slug>`, which the Supervisor pulls, and
tagged `<slug>-v<version>`. Already published versions are skipped.

Apps that wrap an upstream project are versioned
`<upstream version>.<release>`: Renovate updates the upstream version two
weeks after its release, with the release at 0, and merges minor and patch
updates once the checks pass. Changes of the app itself raise the
release.

## Contributing

Changes go through pull requests. Every pull request lints and builds each
app and runs its `test.sh`, if it has one, against the built image. A
change of an app's image or `config.yaml` needs a new version, otherwise
Home Assistant never offers the update; documentation and icons
don't, the Supervisor reads them from the repository.
