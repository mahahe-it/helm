# prometheus-pve-exporter

## TL;DR;

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter
```

## Introduction

A Prometheus exporter for [Proxmox Virtual Environment](https://proxmox.com/en/proxmox-ve) metrics.

This chart bootstraps a [PVE Exporter](https://github.com/gesellix/pve-prometheus-exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter --version <version>
```

These commands deploy prometheus-pve-exporter on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

Add the following to your prometheus configuration:

```yaml
scrape_configs:
  - job_name: 'pve'
    static_configs:
      - targets:
        - 192.168.1.2  # Proxmox VE node.
        - 192.168.1.3  # Proxmox VE node.
    metrics_path: /pve
    params:
      module: [default]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: prometheus-pve-exporter:9221  # PVE exporter service.
```

The following tables list the configurable parameters of the prometheus-pve-exporter chart and their default values.

### Common Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of exporter pods |
| rbac.create | bool | `true` | Create the Role and RoleBinding for the exporter |
| rbac.pspEnabled | bool | `false` | Create a PodSecurityPolicy (removed in Kubernetes 1.25) |
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.name | string | `nil` | ServiceAccount name; generated from the fullname template when empty and `create` is true |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"prompve/prometheus-pve-exporter"` | Image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `9221` | Service port of the metrics endpoint |

### Ingress Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.enabled | bool | `false` | Create an Ingress for the exporter |
| ingress.annotations | object | `{}` | Ingress annotations, e.g. for cert-manager |
| ingress.path | string | `"/"` | Path served by the Ingress |
| ingress.hosts | string | `nil` | Ingress host names (list of strings) |
| ingress.tls | list | `[]` | Ingress TLS configuration |

### PVE Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pve.target | list | `[]` | Proxmox VE node scraped by the ServiceMonitor (`target` parameter) |
| pve.user | string | `"root@pam"` | Proxmox VE user, e.g. `prometheus@pve` |
| pve.password | string | `nil` | Password of `user`; ignored when `token_name` is set |
| pve.verify_ssl | bool | `false` | Verify the TLS certificate of the Proxmox VE API |

### Advanced Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | object | `{}` | Resources of the exporter container, e.g. `{limits: {cpu: 100m, memory: 128Mi}}` |
| nodeSelector | object | `{}` | Node selector for the exporter pods |
| tolerations | list | `[]` | Tolerations for the exporter pods |
| affinity | object | `{}` | Affinity for the exporter pods |
| extraLabels | object | `{}` | Extra labels added to the ServiceMonitor |

### ServiceMonitor Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor for the Prometheus Operator |
| serviceMonitor.namespace | string | `""` | Namespace of the ServiceMonitor, defaults to the release namespace |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor, e.g. the one your Prometheus selects on |
| serviceMonitor.timeout | string | `"10s"` | Scrape timeout |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/prometheus-pve-exporter -f values.yaml
```
