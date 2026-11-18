# Foundry VTT

[Foundry VTT](https://foundryvtt.com/) is a standalone application built for experiencing multiplayer tabletop RPGs using a feature-rich and modern self-hosted application where your players connect directly through the browser.

The chart runs the [felddy/foundryvtt](https://github.com/felddy/foundryvtt-docker) container, which downloads and installs Foundry at startup using your foundryvtt.com account or license.

## TL;DR

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/foundry-vtt \
  --set foundryvtt.username=<foundryvtt.com user> \
  --set foundryvtt.password=<foundryvtt.com password> \
  --set foundryvtt.adminPassword=<admin password>
```

## Prerequisites

- Kubernetes 1.25+
- 512 MB of RAM
- A PV provisioner for persistent data (or `persistence.existingClaim`)

## Installing the Chart

```console
helm install my-release oci://ghcr.io/mahahe-it/helm/foundry-vtt --version <version> -f values.yaml
```

Credentials can come from the values (stored in a Secret created by the chart) or from an existing Secret with `foundryvtt.existingSecret`: it must hold `adminPassword` plus either `username`/`password` (`foundryvtt.existingLicenseType: account`) or `licenseKey` (`foundryvtt.existingLicenseType: licenseKey`).

The [Parameters](#parameters) section lists everything that can be configured.

## Uninstalling the Chart

```console
helm uninstall my-release
```

The PersistentVolumeClaim is kept: delete it by hand to drop the Foundry data.

## Upgrading

### To 1.0.0

Foundry VTT moves from v10 to v14. Back up `/data` before upgrading: Foundry migrates worlds and modules on first start, and the migration cannot be undone.

- Images before felddy/foundryvtt 11.315.1 can no longer log in to foundryvtt.com, so the previous default (10.288) does not start with account credentials anymore.
- The container runs as the non-root `node` user (UID/GID 1000) with a read-only root filesystem. The default `podSecurityContext` sets `fsGroup: 1000` so Kubernetes makes the existing data volume writable for it; with a custom `podSecurityContext`, keep an equivalent `fsGroup`.
- Removed values: `threadCount` (not passed to Foundry by the container anymore), `container.uid`, `container.gid`, `container.preserveOwner`, `foundryvtt.turnConfigs`, `foundryvtt.turnMaxPort` (no longer supported by the container).
- `image.tag` and `foundryvtt.version` default to the version the chart ships; set them only to pin another release.
- `container.timezone` is now passed as `TZ`.
- Probes use Foundry's `/api/status`, with a startup probe (`startupProbe.failureThreshold`, 10 minutes by default) instead of a 10 minute liveness delay.
- The pod hostname is fixed (`podHostname`, default the release fullname) so the license binding survives restarts.
- An empty `persistence.storageClass` now uses the cluster default StorageClass instead of one named `default`.

## Parameters

### Common Parameters

| Name                                       | Description                                                                                                                     | Value            |
| ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| `nameOverride`                             | Name Override                                                                                                                   | `""`             |
| `fullnameOverride`                         | FullName Override                                                                                                               | `""`             |
| `dnsConfig`                                | Override for FoundryVTT DNS Configuration                                                                                       | `{}`             |
| `podHostname`                              | Pod hostname, fixed so the Foundry license binding survives restarts (defaults to the release fullname)                         | `""`             |
| `extraEnv`                                 | Extra environment variables for the container (list of EnvVar)                                                                  | `[]`             |
| `serviceAccount.create`                    | Enable ServiceAccount Creation                                                                                                  | `false`          |
| `serviceAccount.annotations`               | Extra annotations to add to the ServiceAccount                                                                                  | `{}`             |
| `serviceAccount.name`                      | Name of the Service Account                                                                                                     | `nil`            |
| `resources.requests.cpu`                   | Percentile of CPU Requested to run                                                                                              | `500m`           |
| `resources.requests.memory`                | RAM Requested to run                                                                                                            | `512Mi`          |
| `resources.limits.cpu`                     | Maximum CPU allowed                                                                                                             | `1000m`          |
| `resources.limits.memory`                  | Maximum RAM allowed                                                                                                             | `1024Mi`         |
| `podSecurityContext.runAsNonRoot`          | The image runs as the non-root `node` user                                                                                      | `true`           |
| `podSecurityContext.runAsUser`             | UID of the `node` user in the image                                                                                             | `1000`           |
| `podSecurityContext.runAsGroup`            | GID of the `node` user in the image                                                                                             | `1000`           |
| `podSecurityContext.fsGroup`               | Group that owns the data volume, so the `node` user can write to it (also fixes volumes created by chart versions before 1.0.0) | `1000`           |
| `podSecurityContext.fsGroupChangePolicy`   | Only change volume ownership when the root of the volume does not match                                                         | `OnRootMismatch` |
| `podSecurityContext.seccompProfile.type`   | Seccomp profile                                                                                                                 | `RuntimeDefault` |
| `securityContext.allowPrivilegeEscalation` | Allow privilege escalation                                                                                                      | `false`          |
| `securityContext.readOnlyRootFilesystem`   | Read-only root filesystem: Foundry writes to /data and to emptyDir volumes only                                                 | `true`           |
| `securityContext.capabilities.drop`        | Dropped Linux capabilities                                                                                                      | `["ALL"]`        |
| `startupProbe.failureThreshold`            | Startup probe attempts, 10s apart, before liveness takes over (first start downloads Foundry)                                   | `60`             |
| `nodeSelector`                             | Pod Node selector                                                                                                               | `{}`             |
| `tolerations`                              | Pod Tolerations                                                                                                                 | `[]`             |
| `affinity`                                 | Pod Affinity                                                                                                                    | `{}`             |

### Image Parameters

| Name               | Description                                 | Value               |
| ------------------ | ------------------------------------------- | ------------------- |
| `image.pullPolicy` | pullPolicy for the Image                    | `IfNotPresent`      |
| `image.repository` | Repository to take the Image from           | `felddy/foundryvtt` |
| `image.tag`        | Image tag, defaults to the chart appVersion | `""`                |
| `imagePullSecrets` | Credentials for Docker private repository.  | `[]`                |

### FoundryVTT Configuration

| Name                             | Description                                                                                                                                                                                                                                                           | Value                |
| -------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `foundryvtt.username`            | Username of the Account who bought the FoundryVTT License                                                                                                                                                                                                             | `""`                 |
| `foundryvtt.password`            | Password of the Account who bought the FoundryVTT License                                                                                                                                                                                                             | `""`                 |
| `foundryvtt.licenseKey`          | License Key for FoundryVTT. If set the account infos are ignored.                                                                                                                                                                                                     | `""`                 |
| `foundryvtt.existingSecret`      | Name of an existing Secret to fetch the account from. If set, account settings from values are ignored. Must be used in combination with `foundryvtt.existingLicenseType` to fetch the correct data                                                                   | `""`                 |
| `foundryvtt.existingLicenseType` | Type of License to be fetched from the existing secret. Must be either `account` or `licenseKey`. If set to `account`, the `existingSecret` must contain a `username`/`password` data pair. If set to `licenseKey`, the secret must contain a `licenseKey` data entry | `account`            |
| `foundryvtt.hostname`            | Hostname of FoundryVTT                                                                                                                                                                                                                                                | `foundry.domain.com` |
| `foundryvtt.language`            | Language to use                                                                                                                                                                                                                                                       | `en.core`            |
| `foundryvtt.minifyStaticFiles`   | Whether to minify static files or not                                                                                                                                                                                                                                 | `true`               |
| `foundryvtt.proxySSL`            | Indicates whether the software is running behind a reverse proxy that uses SSL. This allows invitation links and A/V functionality to work as if the Foundry Server had SSL configured directly.                                                                      | `true`               |
| `foundryvtt.adminPassword`       | Admin Password to Access Admin Page                                                                                                                                                                                                                                   | `""`                 |
| `foundryvtt.upnp`                | Enable UPNP                                                                                                                                                                                                                                                           | `false`              |
| `foundryvtt.version`             | Foundry VTT version to install, defaults to the one matching the image                                                                                                                                                                                                | `""`                 |
| `foundryvtt.world`               | World to load at startup                                                                                                                                                                                                                                              | `""`                 |
| `foundryvtt.s3.enabled`          | Enable S3 Integration                                                                                                                                                                                                                                                 | `false`              |
| `foundryvtt.s3.existingSecret`   | Existing Secret containing a aws-credentials.json data entry, which must contain supported values by FoundryVTT. More Info [Here](https://foundryvtt.com/article/aws-s3/)                                                                                             | `""`                 |
| `foundryvtt.s3.config.endpoint`  | Custom S3 Endpoint, if different from AWS                                                                                                                                                                                                                             | `""`                 |
| `foundryvtt.s3.config.accessKey` | Access Key ID                                                                                                                                                                                                                                                         | `""`                 |
| `foundryvtt.s3.config.secretKey` | Secret Access Key                                                                                                                                                                                                                                                     | `""`                 |
| `foundryvtt.s3.config.region`    | S3 Bucket Region                                                                                                                                                                                                                                                      | `""`                 |

### Service Parameters

| Name                               | Description                                                              | Value       |
| ---------------------------------- | ------------------------------------------------------------------------ | ----------- |
| `service.serviceType`              | Type of Service to create, defaults to ClusterIP                         | `ClusterIP` |
| `service.port`                     | Port to expose                                                           | `80`        |
| `service.protocol`                 | Protocol to use                                                          | `TCP`       |
| `service.loadBalancerIP`           | IP to assign to the Service if type LoadBalancer is selected, deprecated | `nil`       |
| `service.loadBalancerSourceRanges` | Range from which to choose the IP to assign to the Service               | `[]`        |
| `service.externalTrafficPolicy`    | External Traffic Policy                                                  | `Local`     |
| `service.labels`                   | Extra labels to assign to the Service                                    | `{}`        |
| `service.tls`                      | Enable TLS for the Service                                               | `true`      |
| `service.annotations`              | Extra annotations to assign to the Service                               | `{}`        |

### Persistence Parameters

| Name                          | Description                                                                        | Value               |
| ----------------------------- | ---------------------------------------------------------------------------------- | ------------------- |
| `persistence.enabled`         | Enable or Disable Persistence                                                      | `true`              |
| `persistence.storageClass`    | Storage Class to use when creating the Persistent Volume Claim                     | `""`                |
| `persistence.size`            | Size of the PV to create                                                           | `8Gi`               |
| `persistence.readAccessModes` | List of ReadAccessModes to use with the PVC                                        | `["ReadWriteOnce"]` |
| `persistence.existingClaim`   | Name of an existing claim to use instead of creating a new one. If this is set and | `""`                |

### Extra Container Configurations

| Name                       | Description                                                                                                                                                                                                                                                           | Value                   |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| `container.cache`          | Path to use when downloading FoundryVTT                                                                                                                                                                                                                               | `/data/container_cache` |
| `container.preserveConfig` | Normally new `options.json` and `admin.txt` files are generated by the container at each startup.  Setting this to `true` prevents the container from modifying these files when they exist.  If they do not exist, they will be created as normal. Default is false. | `false`                 |
| `container.timezone`       | Container [TZ database name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List), passed as `TZ`. Default is UTC                                                                                                                                       | `UTC`                   |
| `container.verbose`        | Set to `true` to enable verbose logging for the container utility scripts. Default is false                                                                                                                                                                           | `false`                 |

### Ingress Parameters

| Name                           | Description                                    | Value                |
| ------------------------------ | ---------------------------------------------- | -------------------- |
| `ingress.enabled`              | Enable Ingress creations                       | `false`              |
| `ingress.hostname`             | Hostname for FoundryVTT                        | `foundry.domain.com` |
| `ingress.annotations`          | Ingress Annotations, useful for TLS            | `{}`                 |
| `ingress.path`                 | FoundryVTT Path                                | `/`                  |
| `ingress.pathType`             | Type of Path                                   | `Prefix`             |
| `ingress.tls`                  | Enable or Disable TLS                          | `false`              |
| `ingress.configurationSnippet` | Extra NGINX Configuration to add as Annotation | `""`                 |
| `ingress.className`            | Optional Ingress class name                    | `""`                 |
