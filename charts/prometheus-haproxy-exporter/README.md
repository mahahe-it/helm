# prometheus-haproxy-exporter

## TL;DR;

```console
helm repo add mahahe https://helm.mahahe.it/
helm install my-release mahahe/prometheus-haproxy-exporter
```

## Introduction

A Prometheus exporter for [haproxy](http://www.haproxy.org/) metrics.

This chart bootstraps a [haproxy exporter](https://github.com/prometheus/haproxy_exporter) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled

## Installing the Chart

To install the chart with the release name `my-release`:

```console
helm repo add mahahe https://helm.mahahe.it/
helm install my-release mahahe/prometheus-haproxy-exporter
```

These commands deploy prometheus-haproxy-exporter on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Rbac

| Name              | Description                                             | Value  |
| ----------------- | ------------------------------------------------------- | ------ |
| `rbac.create`     | Specifies whether RBAC resources should be created      | `true` |
| `rbac.pspEnabled` | Specifies whether a PodSecurityPolicy should be created | `true` |


### serviceAccount

| Name                    | Description                                          | Value  |
| ----------------------- | ---------------------------------------------------- | ------ |
| `serviceAccount.create` | Specifies whether a ServiceAccount should be created | `true` |
| `serviceAccount.name`   | The name of the ServiceAccount to use.               | `nil`  |
| `replicaCount`          | Desired number of scaper pods                        | `1`    |


### Image Parameters

| Name               | Description                       | Value                                 |
| ------------------ | --------------------------------- | ------------------------------------- |
| `image.repository` | DockerHub image repository to use | `quay.io/prometheus/haproxy-exporter` |
| `image.tag`        | Image tag to use                  | `v0.13.0`                             |
| `image.pullPolicy` | Pull Policy for the image         | `IfNotPresent`                        |


### Service Parameters

| Name           | Description                                 | Value       |
| -------------- | ------------------------------------------- | ----------- |
| `service.type` | Type of Service to deploy                   | `ClusterIP` |
| `service.port` | Port to use for prometheus-haproxy-exporter | `9101`      |


### Ingress Parameters

| Name                  | Description                                                                                                                                     | Value   |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| `ingress.enabled`     | Enable the creation of an ingress for the  server                                                                                               | `false` |
| `ingress.annotations` | Annotations for the prometheus-haproxy-exporter server ingress. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`    |
| `ingress.tls`         | List of secret for tls key                                                                                                                      | `[]`    |
| `ingress.path`        | path to serve ingress                                                                                                                           | `/`     |
| `ingress.hosts`       | Ingress hostname for the prometheus-haproxy-exporter server ingress                                                                             | `nil`   |


### haproxy Parameters

| Name                 | Description                                                            | Value                                           |
| -------------------- | ---------------------------------------------------------------------- | ----------------------------------------------- |
| `haproxy.verify_ssl` | Enable check if haproxy have valid ssl                                 | `false`                                         |
| `haproxy.scrapeUri`  | Url to scrape at example https://haproxy.example.com/haproxy?stats;csv | `https://haproxy.example.com/haproxy?stats;csv` |
| `haproxy.ExtraArgs`  | extra args pass to container startup                                   | `[]`                                            |


### Advanced parameters

| Name                       | Description                                                                  | Value   |
| -------------------------- | ---------------------------------------------------------------------------- | ------- |
| `resources.limits`         | The resources limits for the YouTrack server containers                      | `{}`    |
| `resources.requests`       | The requested resources for the YouTrack server containers                   | `{}`    |
| `nodeSelector`             | Node labels for YouTrack server pods assignment                              | `{}`    |
| `tolerations`              | Tolerations for YouTrack server pods assignment                              | `[]`    |
| `affinity`                 | Affinity for YouTrack server pods                                            | `{}`    |
| `extraLabels`              | add extraLabels to all object                                                | `{}`    |
| `serviceMonitor.enabled`   | Create ServiceMonitor resource for scraping metrics using PrometheusOperator | `false` |
| `serviceMonitor.namespace` | Namespace in which Prometheus is running                                     | `nil`   |
| `serviceMonitor.interval`  | Interval at which metrics should be scraped                                  | `30s`   |
| `serviceMonitor.labels`    | Extra labels for the ServiceMonitor                                          | `{}`    |
| `serviceMonitor.timeout`   | Specify the timeout after which the scrape is ended                          | `10s`   |

