# MaHaHe website

The website of MaHaHe: [www.mahahe.it](https://www.mahahe.it/) and the Helm
charts page, built with Hugo from [mahahe-it/mahahe-website](https://github.com/mahahe-it/mahahe-website)
and served by an unprivileged nginx. One deployment answers for every host:

| Host | Serves |
|---|---|
| `www.mahahe.it` | the site |
| `helm.mahahe.it` | the frozen legacy HTTPS chart repository (`index.yaml` and the 0.1.x packages); everything else redirects to `https://www.mahahe.it/helm/` |
| `mahahe.it` | redirect to `www.mahahe.it` |

## TL;DR

```console
helm install website oci://ghcr.io/mahahe-it/helm/mahahe-website
```

## Exposing the site

Route the hosts in `hostnames` with an Ingress or, with the Gateway API, an
HTTPRoute. TLS ends there; the pods speak plain HTTP.

```yaml
# Ingress, with cert-manager
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
  tls:
    - secretName: mahahe-website-tls
      hosts: [www.mahahe.it, helm.mahahe.it, mahahe.it]
```

```yaml
# Gateway API: the Gateway listener holds the certificate
httpRoute:
  enabled: true
  parentRefs:
    - name: public
      namespace: gateway
      sectionName: https
```

## Installing the Chart

```console
helm install website oci://ghcr.io/mahahe-it/helm/mahahe-website --version <version> -f values.yaml
```

The pods run as uid 101 with a read-only root filesystem; nginx writes only to
an `emptyDir` on `/tmp`. Health checks use `GET /healthz`.

## Uninstalling the Chart

```console
helm uninstall website
```

## Parameters

### Common Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `2` | Number of nginx pods |
| nameOverride | string | `""` | Partially override the fullname (keeps the release name) |
| fullnameOverride | string | `""` | Fully override the fullname |

### Image Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| image.repository | string | `"ghcr.io/mahahe-it/mahahe-website"` | Image repository |
| image.tag | string | `""` | Image tag, defaults to the chart appVersion |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| imagePullSecrets | list | `[]` | Pull secrets for a private registry |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.type | string | `"ClusterIP"` | Service type |
| service.port | int | `80` | Service port; it forwards to nginx on 8080 |

### Routing Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| hostnames | list | `["www.mahahe.it","helm.mahahe.it","mahahe.it"]` | Host names routed to the site by the Ingress and the HTTPRoute. nginx picks what to serve by host: `www.mahahe.it` is the site, `helm.mahahe.it` serves the legacy HTTPS chart repository and redirects the rest to www, `mahahe.it` redirects to www. |
| ingress.enabled | bool | `false` | Create an Ingress |
| ingress.className | string | `""` | IngressClass name; empty uses the cluster default |
| ingress.annotations | object | `{}` | Ingress annotations, e.g. `cert-manager.io/cluster-issuer` |
| ingress.tls | list | `[]` | TLS configuration, e.g. `[{secretName: mahahe-website-tls, hosts: [www.mahahe.it, helm.mahahe.it, mahahe.it]}]` |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (gateway.networking.k8s.io/v1) |
| httpRoute.parentRefs | list | `[]` | Gateways the route attaches to, e.g. `[{name: public, namespace: gateway, sectionName: https}]`; required when enabled |
| httpRoute.annotations | object | `{}` | HTTPRoute annotations |

### Security Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| podSecurityContext | object | `{"runAsGroup":101,"runAsNonRoot":true,"runAsUser":101,"seccompProfile":{"type":"RuntimeDefault"}}` | Pod security context: nginx-unprivileged runs as uid 101 |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true}` | Container security context: read-only root filesystem, nginx writes to an emptyDir on /tmp |

### Advanced Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | object | `{"limits":{"memory":"64Mi"},"requests":{"cpu":"10m","memory":"16Mi"}}` | Container resources |
| podAnnotations | object | `{}` | Extra pod annotations |
| nodeSelector | object | `{}` | Node selector |
| tolerations | list | `[]` | Tolerations |
| affinity | object | `{}` | Affinity |
