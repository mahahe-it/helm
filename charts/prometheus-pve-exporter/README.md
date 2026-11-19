# prometheus-pve-exporter

Prometheus exporter for Proxmox VE metrics (prometheus-pve-exporter)

## TL;DR

```console
helm install pve-exporter oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter -f values.yaml
```

## Introduction

This chart runs [prometheus-pve-exporter](https://github.com/prometheus-pve/prometheus-pve-exporter),
which reads metrics of [Proxmox VE](https://proxmox.com/en/proxmox-ve) hosts
through their API and serves them on `/pve?target=<host>`.

## Prerequisites

- Kubernetes 1.25+
- A read-only Proxmox VE user (PVEAuditor role on `/`), ideally with an API token

## Installing the Chart

```yaml
# values.yaml
pve:
  user: prometheus@pve
  token_name: exporter
  token_value: 00000000-0000-0000-0000-000000000000
serviceMonitor:
  enabled: true
  targets:
    - pve1.example.com
    - pve2.example.com
  labels:
    release: kube-prometheus-stack  # what your Prometheus selects on
```

```console
helm install pve-exporter oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter --version <version> -f values.yaml
```

To keep the credentials out of the values, create a Secret with a `pve.yml`
key in the [exporter format](https://github.com/prometheus-pve/prometheus-pve-exporter#authentication)
and set `pve.existingSecret`.

## Scraping

With the Prometheus Operator, `serviceMonitor.enabled` creates a ServiceMonitor
with one endpoint per host in `serviceMonitor.targets`, labelled
`instance=<host>`. Without it, add a scrape job to Prometheus:

```yaml
scrape_configs:
  - job_name: pve
    static_configs:
      - targets:
          - pve1.example.com  # Proxmox VE hosts
    metrics_path: /pve
    params:
      module: [default]
      cluster: ['1']
      node: ['1']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: pve-exporter-prometheus-pve-exporter.monitoring:9221  # the chart Service
```

## Upgrading

### From chart 1.x to 2.x

The chart moves to prometheus-pve-exporter v3:

- The configuration is mounted on `/etc/prometheus/pve.yml` and passed with
  `--config.file`; the container runs as uid 101 with a read-only root filesystem.
- `pve.target` is now `serviceMonitor.targets`, a list with one scrape endpoint
  per host. `serviceMonitor.params` sets `module`, `cluster` and `node`.
- `extraLabels` is gone: use `serviceMonitor.labels`, which can now set
  `release` without breaking the manifest.
- `rbac.create` and `rbac.pspEnabled` are gone with the PodSecurityPolicy
  (removed in Kubernetes 1.25) and its Role.
- The Ingress uses `networking.k8s.io/v1`: set the hosts in `hostnames`, then
  `ingress.className`, `ingress.annotations`, `ingress.tls`; `ingress.hosts` and
  `ingress.path` are gone. An HTTPRoute is available as `httpRoute.*`.
- `extraArgs` passes exporter flags such as `--no-collector.config`.

The Deployment selector is unchanged, so `helm upgrade` works in place.

## Uninstalling the Chart

```console
helm uninstall pve-exporter
```

## Parameters

### Common Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of exporter pods |
| nameOverride | string | `""` | Partially override the fullname (keeps the release name) |
| fullnameOverride | string | `""` | Fully override the fullname |
| serviceAccount.create | bool | `true` | Create a ServiceAccount (the exporter does not use the Kubernetes API, its token is not mounted) |
| serviceAccount.name | string | `""` | ServiceAccount name; generated from the fullname when empty and `create` is true |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"prompve/prometheus-pve-exporter"` | Image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| imagePullSecrets | list | `[]` | Pull secrets for a private registry |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `9221` | Service port of the metrics endpoint |

### Routing Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hostnames | list | `[]` | Host names routed to the exporter by the Ingress and the HTTPRoute; required when either is enabled. Upstream advises against exposing the exporter to public networks. |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.className | string | `""` | IngressClass name; empty uses the cluster default |
| ingress.annotations | object | `{}` | Ingress annotations, e.g. `cert-manager.io/cluster-issuer` |
| ingress.tls | list | `[]` | TLS configuration, e.g. `[{secretName: pve-exporter-tls, hosts: [pve-exporter.example.com]}]` |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (gateway.networking.k8s.io/v1) |
| httpRoute.parentRefs | list | `[]` | Gateways the route attaches to, e.g. `[{name: public, namespace: gateway, sectionName: https}]`; required when enabled |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |

### PVE Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pve.user | string | `"root@pam"` | Proxmox VE user, e.g. `prometheus@pve` |
| pve.password | string | `""` | Password of `user`; ignored when `token_name` is set |
| pve.token_name | string | `""` | API token name, used instead of the password when set |
| pve.token_value | string | `""` | API token secret |
| pve.verify_ssl | bool | `false` | Verify the TLS certificate of the Proxmox VE API |
| pve.existingSecret | string | `""` | Existing Secret with a `pve.yml` key; when set, the values above are ignored and no Secret is created |

### Security Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| podSecurityContext | object | `{"runAsGroup":101,"runAsNonRoot":true,"runAsUser":101,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context: the v3 image runs as prometheus (101:101) |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context: read-only root filesystem, /tmp is an emptyDir |

### Advanced Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | object | `{}` | Resources of the exporter container, e.g. `{limits: {cpu: 100m, memory: 128Mi}}` |
| podAnnotations | object | `{}` | Extra pod annotations |
| nodeSelector | object | `{}` | Node selector for the exporter pods |
| tolerations | list | `[]` | Tolerations for the exporter pods |
| affinity | object | `{}` | Affinity for the exporter pods |

### ServiceMonitor Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor for the Prometheus Operator |
| serviceMonitor.targets | list | `[]` | Proxmox VE hosts to scrape, one endpoint each (`target` parameter, also the `instance` label); required when enabled |
| serviceMonitor.params | object | `{"cluster":["1"],"module":["default"],"node":["1"]}` | Other scrape parameters. For large clusters upstream advises separate cluster and node scrapes |
| serviceMonitor.namespace | string | `""` | Namespace of the ServiceMonitor, defaults to the release namespace |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.timeout | string | `"10s"` | Scrape timeout |
| serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor, e.g. `release` for kube-prometheus-stack |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraArgs | list | `[]` |  |
