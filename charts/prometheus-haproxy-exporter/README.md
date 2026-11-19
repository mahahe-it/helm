# prometheus-haproxy-exporter

> **Deprecated.** The upstream [haproxy_exporter](https://github.com/prometheus/haproxy_exporter)
> is archived and v0.15.0 is its final release. HAProxy 2.0 and later expose
> Prometheus metrics natively: enable the
> [Prometheus exporter](https://www.haproxy.com/documentation/haproxy-configuration-tutorials/alerts-and-monitoring/prometheus/)
> in HAProxy (`http-request use-service prometheus-exporter`) and scrape it
> directly. This chart gets no further releases.

## TL;DR;

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/prometheus-haproxy-exporter
```

## Introduction

A Prometheus exporter for [haproxy](http://www.haproxy.org/) metrics.

This chart bootstraps a [haproxy exporter](https://github.com/prometheus/haproxy_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.25+

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/prometheus-haproxy-exporter --version <version>
```

These commands deploy prometheus-haproxy-exporter on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Common Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of exporter pods |
| serviceAccount.create | bool | `true` | Create a ServiceAccount |
| serviceAccount.name | string | `nil` | ServiceAccount name; generated from the fullname template when empty and `create` is true |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"quay.io/prometheus/haproxy-exporter"` | Image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `9101` | Service port of the metrics endpoint |

### Ingress Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ingress.enabled | bool | `false` | Create an Ingress for the exporter |
| ingress.annotations | object | `{}` | Ingress annotations, e.g. for cert-manager |
| ingress.path | string | `"/"` | Path served by the Ingress |
| ingress.hosts | string | `nil` | Ingress host names (list of strings) |
| ingress.tls | list | `[]` | Ingress TLS configuration |

### HAProxy Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| haproxy.verify_ssl | bool | `false` | Verify the TLS certificate of the HAProxy stats endpoint; `false` adds `--no-haproxy.ssl-verify` |
| haproxy.scrapeUri | string | `"https://haproxy.example.com/haproxy?stats;csv"` | HAProxy stats URI to scrape (`--haproxy.scrape-uri`) |
| haproxy.ExtraArgs | list | `[]` | Extra arguments for the exporter |

### Advanced Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources.limits | object | `{}` | Resource limits of the exporter container, e.g. `{cpu: 100m, memory: 128Mi}` |
| resources.requests | object | `{}` | Resource requests of the exporter container |
| nodeSelector | object | `{}` | Node selector for the exporter pods |
| tolerations | list | `[]` | Tolerations for the exporter pods |
| affinity | object | `{}` | Affinity for the exporter pods |
| extraLabels | object | `{}` | Extra labels added to the ServiceMonitor |

### ServiceMonitor Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| serviceMonitor.enabled | bool | `false` | Create a ServiceMonitor for the Prometheus Operator |
| serviceMonitor.namespace | string | `nil` | Namespace of the ServiceMonitor, defaults to the release namespace |
| serviceMonitor.interval | string | `"30s"` | Scrape interval |
| serviceMonitor.labels | object | `{}` | Extra labels for the ServiceMonitor, e.g. the one your Prometheus selects on |
| serviceMonitor.timeout | string | `"10s"` | Scrape timeout |
