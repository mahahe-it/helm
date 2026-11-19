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

## Exposing Foundry

Route the hosts in `hostnames` with an Ingress or, with the Gateway API, an
HTTPRoute; TLS ends there. Set `foundryvtt.hostname` to the public host as well,
so Foundry shows the right invitation links. Foundry uses WebSockets, which
both the Ingress controllers and the Gateway API implementations in common use
pass through.

```yaml
# Ingress, with cert-manager
hostnames:
  - vtt.example.com
ingress:
  enabled: true
  className: nginx
  tls: true  # secret <fullname>-tls, for every host
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
```

```yaml
# Gateway API
hostnames:
  - vtt.example.com
httpRoute:
  enabled: true
  parentRefs:
    - name: public
      namespace: gateway
      sectionName: https
```

`ingress.hostname` still works when `hostnames` is empty.
`ingress.configurationSnippet` is specific to ingress-nginx and has no
HTTPRoute equivalent.

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

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` | Name Override |
| fullnameOverride | string | `""` | FullName Override |
| dnsConfig | object | `{}` | Override for FoundryVTT DNS Configuration |
| podHostname | string | `""` | Pod hostname, fixed so the Foundry license binding survives restarts (defaults to the release fullname) |
| extraEnv | list | `[]` | Extra environment variables for the container (list of EnvVar) |
| serviceAccount.create | bool | `false` | Enable ServiceAccount Creation |
| serviceAccount.annotations | object | `{}` | Extra annotations to add to the ServiceAccount |
| serviceAccount.name | string | `nil` | Name of the Service Account |
| resources.requests.cpu | string | `"500m"` | Percentile of CPU Requested to run |
| resources.requests.memory | string | `"512Mi"` | RAM Requested to run |
| resources.limits.cpu | string | `"1000m"` | Maximum CPU allowed |
| resources.limits.memory | string | `"1024Mi"` | Maximum RAM allowed |
| podSecurityContext.runAsNonRoot | bool | `true` | The image runs as the non-root `node` user |
| podSecurityContext.runAsUser | int | `1000` | UID of the `node` user in the image |
| podSecurityContext.runAsGroup | int | `1000` | GID of the `node` user in the image |
| podSecurityContext.fsGroup | int | `1000` | Group that owns the data volume, so the `node` user can write to it (also fixes volumes created by chart versions before 1.0.0) |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` | Only change volume ownership when the root of the volume does not match |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` | Seccomp profile |
| securityContext.allowPrivilegeEscalation | bool | `false` | Allow privilege escalation |
| securityContext.readOnlyRootFilesystem | bool | `true` | Read-only root filesystem: Foundry writes to /data and to emptyDir volumes only |
| securityContext.capabilities.drop | list | `["ALL"]` | Dropped Linux capabilities |
| startupProbe.failureThreshold | int | `60` | Startup probe attempts, 10s apart, before liveness takes over (first start downloads Foundry) |
| nodeSelector | object | `{}` | Pod Node selector |
| tolerations | list | `[]` | Pod Tolerations |
| affinity | object | `{}` | Pod Affinity |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.pullPolicy | string | `"IfNotPresent"` | pullPolicy for the Image |
| image.repository | string | `"felddy/foundryvtt"` | Repository to take the Image from |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| imagePullSecrets | list | `[]` | Credentials for Docker private repository. |

### FoundryVTT Configuration

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| foundryvtt.username | string | `""` | Username of the Account who bought the FoundryVTT License |
| foundryvtt.password | string | `""` | Password of the Account who bought the FoundryVTT License |
| foundryvtt.existingLicenseType | string | `"account"` | Type of License to be fetched from the existing secret. Must be either `account` or `licenseKey`. If set to `account`, the `existingSecret` must contain a `username`/`password` data pair. If set to `licenseKey`, the secret must contain a `licenseKey` data entry |
| foundryvtt.existingSecret | string | `""` | Name of an existing Secret to fetch the account from. If set, account settings from values are ignored. Must be used in combination with `foundryvtt.existingLicenseType` to fetch the correct data |
| foundryvtt.licenseKey | string | `""` | License Key for FoundryVTT. If set the account infos are ignored. |
| foundryvtt.adminPassword | string | `""` | Admin Password to Access Admin Page |
| foundryvtt.hostname | string | `"foundry.domain.com"` | Hostname of FoundryVTT |
| foundryvtt.language | string | `"en.core"` | Language to use |
| foundryvtt.minifyStaticFiles | bool | `true` | Whether to minify static files or not |
| foundryvtt.proxySSL | bool | `true` | Indicates whether the software is running behind a reverse proxy that uses SSL. This allows invitation links and A/V functionality to work as if the Foundry Server had SSL configured directly. |
| foundryvtt.s3.enabled | bool | `false` | Enable S3 Integration |
| foundryvtt.s3.existingSecret | string | `""` | Existing Secret containing a aws-credentials.json data entry, which must contain supported values by FoundryVTT. More Info [Here](https://foundryvtt.com/article/aws-s3/) |
| foundryvtt.s3.config.accessKey | string | `""` | Access Key ID |
| foundryvtt.s3.config.secretKey | string | `""` | Secret Access Key |
| foundryvtt.s3.config.region | string | `""` | S3 Bucket Region |
| foundryvtt.s3.config.endpoint | string | `""` | Custom S3 Endpoint, if different from AWS |
| foundryvtt.upnp | bool | `false` | Enable UPNP |
| foundryvtt.version | string | `""` | Foundry VTT version to install, defaults to the one matching the image |
| foundryvtt.world | string | `""` | World to load at startup |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.serviceType | string | `"ClusterIP"` | Type of Service to create, defaults to ClusterIP |
| service.port | int | `80` | Port to expose |
| service.protocol | string | `"TCP"` | Protocol to use |
| service.loadBalancerIP | string | `nil` | IP to assign to the Service if type LoadBalancer is selected, deprecated |
| service.loadBalancerSourceRanges | list | `[]` | Range from which to choose the IP to assign to the Service |
| service.externalTrafficPolicy | string | `"Local"` | External Traffic Policy |
| service.labels | object | `{}` | Extra labels to assign to the Service |
| service.tls | bool | `true` | Enable TLS for the Service |
| service.annotations | object | `{}` | Extra annotations to assign to the Service |

### Persistence Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.enabled | bool | `true` | Enable or Disable Persistence |
| persistence.storageClass | string | `""` | Storage Class to use when creating the Persistent Volume Claim |
| persistence.size | string | `"8Gi"` | Size of the PV to create |
| persistence.readAccessModes | list | `["ReadWriteOnce"]` | List of ReadAccessModes to use with the PVC |
| persistence.existingClaim | string | `""` | Name of an existing claim to use instead of creating a new one. If this is set and |

### Extra Container Configurations

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| container.cache | string | `"/data/container_cache"` | Path to use when downloading FoundryVTT |
| container.preserveConfig | bool | `false` | Normally new `options.json` and `admin.txt` files are generated by the container at each startup.  Setting this to `true` prevents the container from modifying these files when they exist.  If they do not exist, they will be created as normal. Default is false. |
| container.timezone | string | `"UTC"` | Container [TZ database name](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List), passed as `TZ`. Default is UTC |
| container.verbose | bool | `false` | Set to `true` to enable verbose logging for the container utility scripts. Default is false |

### Ingress Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hostnames | list | `[]` | Host names routed to Foundry by the Ingress and the HTTPRoute. When empty, `ingress.hostname` is used |
| ingress.enabled | bool | `false` | Enable Ingress creations |
| ingress.hostname | string | `"foundry.domain.com"` | Single host name, used when `hostnames` is empty (kept for compatibility, prefer `hostnames`) |
| ingress.annotations | object | `{}` | Ingress Annotations, useful for TLS |
| ingress.path | string | `"/"` | FoundryVTT Path |
| ingress.pathType | string | `"Prefix"` | Type of Path |
| ingress.configurationSnippet | string | `""` | Extra NGINX Configuration to add as Annotation |
| ingress.tls | bool | `false` | Enable or Disable TLS |
| ingress.className | string | `""` | Optional Ingress class name |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (gateway.networking.k8s.io/v1) |
| httpRoute.parentRefs | list | `[]` | Gateways the route attaches to, e.g. `[{name: public, namespace: gateway, sectionName: https}]`; required when enabled |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |
