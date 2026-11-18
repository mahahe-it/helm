# MaHaHe Helm Repository

## Deprecation Warning
Starting from `20-04-2026`, all HTTPS based releases are to be considered **deprecated**. If you're still using the repository `https://helm.mahahe.it`, please switch to the new OCI based charts: no `helm repo add` is needed.

## TL;DR
```bash
helm install myrelease oci://ghcr.io/mahahe-it/helm/{chart}

# Optionally with version
helm install myrelease oci://ghcr.io/mahahe-it/helm/{chart} --version={version}

# Inspect a chart before installing it
helm show values oci://ghcr.io/mahahe-it/helm/{chart}
```

#### Welcome!

Welcome to the Official MaHaHe Helm Repository! Here you will find various applications packaged and released by MaHaHe, just browse our [repository](https://github.com/mahahe-it/helm), look at the available charts, choose one and install it!

#### Available Charts

| Chart | Install |
|---|---|
| [Foundry VTT](https://github.com/mahahe-it/helm/tree/main/charts/foundry-vtt) | `oci://ghcr.io/mahahe-it/helm/foundry-vtt` |
| [Prometheus HAProxy Exporter](https://github.com/mahahe-it/helm/tree/main/charts/prometheus-haproxy-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-haproxy-exporter` |
| [Prometheus PVE Exporter](https://github.com/mahahe-it/helm/tree/main/charts/prometheus-pve-exporter) | `oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter` |
| [YouTrack](https://github.com/mahahe-it/helm/tree/main/charts/youtrack) | `oci://ghcr.io/mahahe-it/helm/youtrack` |

Versions and changelogs are on the [GitHub releases](https://github.com/mahahe-it/helm/releases) page.

#### License

This website and every content used by it is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).
