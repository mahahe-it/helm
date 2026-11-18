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
| [MaHaHe website](charts/mahahe-website) | `oci://ghcr.io/mahahe-it/helm/mahahe-website` |
| [Prometheus HAProxy Exporter](charts/prometheus-haproxy-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-haproxy-exporter` |
| [Prometheus PVE Exporter](charts/prometheus-pve-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter` |
| [YouTrack](charts/youtrack) | `oci://ghcr.io/mahahe-it/helm/youtrack` |

Versions and changelogs are on the [releases](https://github.com/mahahe-it/helm/releases) page.

### License

This repository is licensed under the [Apache License 2.0](https://github.com/mahahe-it/helm/blob/main/LICENSE).

### Maintainers
This repository is maintained by the MaHaHe DevOps Team. You can contact us at [devops@mahahe.it](mailto:devops@mahahe.it).

### Contribution

Issues and pull requests are welcome: [CONTRIBUTING.md](CONTRIBUTING.md) explains
the development setup, the PR title convention that drives chart releases, and
how releases are published. Please follow our
[Code of Conduct](https://github.com/mahahe-it/.github/blob/main/CODE_OF_CONDUCT.md)
and report security problems as described in the
[Security Policy](https://github.com/mahahe-it/.github/blob/main/SECURITY.md).
