# YouTrack by MaHaHe

YouTrack is a project management tool that can be adapted to your processes to help you deliver great products.

[Overview of YouTrack](https://www.jetbrains.com/youtrack/)

## TL;DR

```console
helm install youtrack oci://ghcr.io/mahahe-it/helm/youtrack
```

## Introduction

This chart runs [YouTrack](https://www.jetbrains.com/youtrack/) as a single-instance
StatefulSet with the official `jetbrains/youtrack` image, keeping `data`, `conf`,
`logs` and `backups` on one PersistentVolumeClaim each. YouTrack needs at least
1.5 GB of RAM: set `resources` accordingly. NFS volumes are not supported by
YouTrack.

## Installing the Chart

```console
helm install youtrack oci://ghcr.io/mahahe-it/helm/youtrack --version <version> -f values.yaml
```

The first start opens the Configuration Wizard, which asks for a token printed
in the log:

```console
kubectl logs youtrack-0 | grep wizard_token
```

## Exposing YouTrack

Route the hosts in `hostnames` with an Ingress or, with the Gateway API, an
HTTPRoute. TLS ends there; the pod speaks plain HTTP on 8080.

```yaml
# Ingress, with cert-manager
hostnames:
  - youtrack.example.com
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  tls:
    - secretName: youtrack-tls
      hosts: [youtrack.example.com]
```

```yaml
# Gateway API
hostnames:
  - youtrack.example.com
httpRoute:
  enabled: true
  parentRefs:
    - name: public
      namespace: gateway
      sectionName: https
```

## Upgrading

### YouTrack versions

YouTrack has no forward database compatibility and does not support every
upgrade in one step: follow JetBrains'
[recommended upgrade path](https://www.jetbrains.com/help/youtrack/server/upgrade-with-docker-image.html).
For every step:

1. Create a backup in YouTrack (Administration, Database Backup); it lands on the
   `backups` volume. Copy it somewhere safe as well.
2. Set `image.tag` to the next version and run `helm upgrade`.
3. Open YouTrack and complete the Configuration Wizard with the token from the
   log (see above). Wait until YouTrack is up before the next step.

From YouTrack 2022.x (chart 1.x) to the 2026.2 of chart 2.x the steps are:

| Step | `image.tag` |
| ---- | ----------- |
| 1 | `2023.1.22653` |
| 2 | `2023.3.26285` |
| 3 | `2024.3.148430` |
| 4 | `2025.2.148048` |
| 5 | `2025.3.172487` |
| 6 | empty (the chart appVersion) |

To roll back, restore the backup taken before the failed step.

### From chart 1.x to 2.x

- The Ingress values changed: `ingress.hostname`, `ingress.hosts`,
  `ingress.extraHosts`, `ingress.path` and the other 1.x keys are gone. Set the
  hosts in `hostnames` and use `ingress.className`, `ingress.annotations` and
  `ingress.tls` (the 1.x Ingress created no rules anyway).
- The default image is YouTrack 2026.2: upgrade through the versions above
  first, with `image.tag`, on chart 2.x. `helm upgrade` refuses to move a
  YouTrack older than 2025.3 to the chart appVersion while `image.tag` is empty.
- `persistence.*` now configures the volumes. Its defaults match the 1.x
  volumes, so an upgrade keeps them.

### Changing the volumes

A StatefulSet cannot change its `volumeClaimTemplates`, so `persistence.*`
applies to new installations only. To change it on an existing release, delete
the StatefulSet keeping the pod and the PVCs, then upgrade:

```console
kubectl delete statefulset youtrack --cascade=orphan
helm upgrade youtrack oci://ghcr.io/mahahe-it/helm/youtrack -f values.yaml
```

Existing PVCs keep their size and class: resize them with
`kubectl edit pvc` if the storage class allows expansion.

## Uninstalling the Chart

```console
helm uninstall youtrack
```

The PersistentVolumeClaims stay: delete them by hand to drop the data.

## Parameters

### Common Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` | Number of YouTrack pods: YouTrack runs a single instance, so 1, or 0 to stop it (e.g. to restore a backup) |
| nameOverride | string | `""` | Partially override the fullname (keeps the release name) |
| fullnameOverride | string | `""` | Fully override the fullname |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"jetbrains/youtrack"` | Image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion. Set it to step through the intermediate versions of an upgrade (see Upgrading) |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| imagePullSecrets | list | `[]` | Pull secrets for a private registry |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `8080` | Service port; it forwards to YouTrack on 8080 |

### Routing Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hostnames | list | `[]` | Host names routed to YouTrack by the Ingress and the HTTPRoute; required when either is enabled |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.className | string | `""` | IngressClass name; empty uses the cluster default |
| ingress.annotations | object | `{}` | Ingress annotations, e.g. `cert-manager.io/cluster-issuer` |
| ingress.tls | list | `[]` | TLS configuration, e.g. `[{secretName: youtrack-tls, hosts: [youtrack.example.com]}]` |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (gateway.networking.k8s.io/v1) |
| httpRoute.parentRefs | list | `[]` | Gateways the route attaches to, e.g. `[{name: public, namespace: gateway, sectionName: https}]`; required when enabled |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |

### Storage Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.storageClass | string | `""` | Storage class for every volume; empty uses the cluster default. NFS is not supported by YouTrack |
| persistence.data.size | string | `"10Gi"` | Size of the data volume (database) |
| persistence.data.storageClass | string | `""` | Storage class of the data volume, overrides `persistence.storageClass` |
| persistence.data.accessModes | list | `["ReadWriteOnce"]` | Access modes of the data volume |
| persistence.conf.size | string | `"1Gi"` | Size of the conf volume |
| persistence.conf.storageClass | string | `""` | Storage class of the conf volume, overrides `persistence.storageClass` |
| persistence.conf.accessModes | list | `["ReadWriteOnce"]` | Access modes of the conf volume |
| persistence.logs.size | string | `"2Gi"` | Size of the logs volume |
| persistence.logs.storageClass | string | `""` | Storage class of the logs volume, overrides `persistence.storageClass` |
| persistence.logs.accessModes | list | `["ReadWriteOnce"]` | Access modes of the logs volume |
| persistence.backups.size | string | `"10Gi"` | Size of the backups volume |
| persistence.backups.storageClass | string | `""` | Storage class of the backups volume, overrides `persistence.storageClass` |
| persistence.backups.accessModes | list | `["ReadWriteOnce"]` | Access modes of the backups volume |

### Security Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| podSecurityContext | object | `{"fsGroup":13001,"runAsGroup":13001,"runAsNonRoot":true,"runAsUser":13001}` | Pod security context: the image runs as 13001:13001 |

### Advanced Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| readinessProbe | object | `{"initialDelaySeconds":10,"periodSeconds":10,"tcpSocket":{"port":"http"}}` | Readiness probe. There is no liveness probe: a restart during a database upgrade would break it |
| resources | object | `{}` | Container resources. YouTrack needs at least 1.5 GB of RAM and recommends 2 CPUs |
| podAnnotations | object | `{}` | Extra pod annotations |
| nodeSelector | object | `{}` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity |
