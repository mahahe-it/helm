[![ArtifactHub](https://img.shields.io/static/v1?label=ArtifactHub&message=Organization&labelColor=EBEBEB&color=417598&logo=ArtifactHub)](https://artifacthub.io/packages/search?org=mahahe-it&sort=relevance&page=1)
[![CI](https://github.com/mahahe-it/helm/actions/workflows/ci.yaml/badge.svg)](https://github.com/mahahe-it/helm/actions/workflows/ci.yaml)
[![Release](https://github.com/mahahe-it/helm/actions/workflows/release.yaml/badge.svg)](https://github.com/mahahe-it/helm/actions/workflows/release.yaml)

# Mahahe©️ Official Helm Repository
Applications ready to launch on Kubernetes using [Helm](https://github.com/helm/helm)

### TL;DR
```console
helm install my-release oci://ghcr.io/mahahe-it/helm/<chart>
helm install my-release oci://ghcr.io/mahahe-it/helm/<chart> --version <version>
```

Charts are published as OCI artifacts on GHCR, so no `helm repo add` is needed.
The HTTPS repository `https://helm.mahahe.it/` (`index.yaml`) is deprecated since
2026-04-20 and receives no new releases: switch to the `oci://` URLs above.

### Welcome!

Welcome to the Official MaHaHe Helm Repository! Here you will find various applications packaged and released by MaHaHe, just browse our [repository](https://github.com/mahahe-it/helm), look at the available charts, choose one and install it!

### Available Charts

The applications we offer at the moment:

| Chart | Install |
|---|---|
| [Foundry VTT](charts/foundry-vtt) | `oci://ghcr.io/mahahe-it/helm/foundry-vtt` |
| [Prometheus HAProxy Exporter](charts/prometheus-haproxy-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-haproxy-exporter` |
| [Prometheus PVE Exporter](charts/prometheus-pve-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter` |
| [YouTrack](charts/youtrack) | `oci://ghcr.io/mahahe-it/helm/youtrack` |

Versions and changelogs are on the [releases](https://github.com/mahahe-it/helm/releases) page.

### License

This repository is licensed under the [Apache License 2.0](https://github.com/mahahe-it/helm/blob/main/LICENSE).

### Maintainers
This repository is maintained by the MaHaHe DevOps Team. You can contact us at [devops@mahahe.it](mailto:devops@mahahe.it).

### Contribution

Tools are pinned in `.devcontainer/Dockerfile`: open the repo in the devcontainer,
or run `just toolbox` to build the same image as a distrobox. `just --list` shows
the common tasks (lint, template, docs, unittest, test on kind).

Changes go through pull requests, merged by squash. The PR title alone becomes
the commit on `main`, so it must follow [Conventional Commits](https://www.conventionalcommits.org/),
and it drives the chart version:

| PR title | Chart release |
|---|---|
| `fix(youtrack): ...` | patch |
| `feat(youtrack): ...` | minor |
| `feat(youtrack)!: ...` (breaking change) | major |
| `docs`, `chore`, `ci`, `test`, ... | none |

The chart a change belongs to is the directory it touches; the scope is for
readers. Do not bump `version` in `Chart.yaml`: [release-please](https://github.com/googleapis/release-please)
keeps a release PR open with the next version of every changed chart and its
`CHANGELOG.md`. Merging it tags `<chart>-<version>`, creates the GitHub release
and publishes the chart to `oci://ghcr.io/mahahe-it/helm/<chart>`.
Renovate opens the PRs for upstream image and tooling updates.

Files must use LF line endings (`git config --global core.autocrlf false` on Windows).
