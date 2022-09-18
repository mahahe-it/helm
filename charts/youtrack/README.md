# YouTrack by MaHaHe

YouTrack is a project management tool that can be adapted to your processes to help you deliver great products.

[Overview of YouTrack](https://www.jetbrains.com/youtrack/)
                           
## TL;DR

```console
$ helm repo add mahahe https://charts.mahahe.it/
$ helm install my-release mahahe/youtrack
```

## Introduction

This chart bootstraps a [YouTrack](https://github.com/mahahe-it/helm/tree/main/charts/youtrack) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release mahahe/youtrack
```

The command deploys YouTrack on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Common Parameters

| Name               | Description                                         | Value |
| ------------------ | --------------------------------------------------- | ----- |
| `replicaCount`     | Number of Replicas to deploy                        | `1`   |
| `nameOverride`     | String to partially override common.names.fullname  | `""`  |
| `fullnameOverride` | String to fully override common.names.fullname      | `""`  |


### Image Parameters

| Name               | Description                       | Value                |
| ------------------ | --------------------------------- | -------------------- |
| `image.repository` | DockerHub image repository to use | `jetbrains/youtrack` |
| `image.tag`        | Image tag to use                  | `2022.2.55618`       |
| `image.pullPolicy` | Pull Policy for the image         | `IfNotPresent`       |


### Service Parameters

| Name           | Description               | Value       |
| -------------- | ------------------------- | ----------- |
| `service.type` | Type of Service to deploy | `ClusterIP` |
| `service.port` | Port to use for YouTrack  | `8080`      |


### Ingress Parameters

| Name                       | Description                                                                                                                  | Value                    |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `ingress.enabled`          | Enable the creation of an ingress for the YouTrack server                                                                    | `false`                  |
| `ingress.pathType`         | Path type for the YouTrack server ingress                                                                                    | `ImplementationSpecific` |
| `ingress.apiVersion`       | Ingress API version for the YouTrack server ingress                                                                          | `""`                     |
| `ingress.hostname`         | Ingress hostname for the YouTrack server ingress                                                                             | `youtrack.server.local`  |
| `ingress.annotations`      | Annotations for the YouTrack server ingress. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `ingress.tls`              | Enable TLS for the YouTrack server ingress                                                                                   | `false`                  |
| `ingress.extraHosts`       | Extra hosts array for the YouTrack server ingress                                                                            | `[]`                     |
| `ingress.path`             | Path array for the YouTrack server ingress                                                                                   | `/`                      |
| `ingress.extraPaths`       | Extra paths for the YouTrack server ingress                                                                                  | `[]`                     |
| `ingress.extraTls`         | Extra TLS configuration for the YouTrack server ingress                                                                      | `[]`                     |
| `ingress.secrets`          | Secrets array to mount into the Ingress                                                                                      | `[]`                     |
| `ingress.ingressClassName` | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                | `""`                     |
| `ingress.selfSigned`       | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                 | `false`                  |
| `ingress.extraRules`       | Additional rules to be covered with this ingress record                                                                      | `[]`                     |
| `resources.limits`         | The resources limits for the YouTrack server containers                                                                      | `{}`                     |
| `resources.requests`       | The requested resources for the YouTrack server containers                                                                   | `{}`                     |
| `nodeSelector`             | Node labels for YouTrack server pods assignment                                                                              | `{}`                     |
| `tolerations`              | Tolerations for YouTrack server pods assignment                                                                              | `[]`                     |
| `affinity`                 | Affinity for YouTrack server pods                                                                                            | `{}`                     |

