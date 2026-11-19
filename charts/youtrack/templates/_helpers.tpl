{{/*
Chart name, overridable with nameOverride.
*/}}
{{- define "youtrack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified app name: the release name alone when it already contains the
chart name. Truncated at 63 chars (DNS label limit).
*/}}
{{- define "youtrack.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "youtrack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "youtrack.labels" -}}
helm.sh/chart: {{ include "youtrack.chart" . }}
{{ include "youtrack.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels: immutable on the StatefulSet, keep them as in 1.x.
*/}}
{{- define "youtrack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "youtrack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Fail when the Ingress or the HTTPRoute has no host to route.
*/}}
{{- define "youtrack.requireHostnames" -}}
{{- if not .Values.hostnames -}}
{{- fail "hostnames needs at least one host for the Ingress or the HTTPRoute" -}}
{{- end -}}
{{- end -}}

{{/*
Upgrade guard: YouTrack before 2025.3 cannot jump to the chart appVersion in one
step. On helm upgrade (lookup is empty on install and template), fail when the
running image is older and image.tag does not pick an intermediate version.
*/}}
{{- define "youtrack.upgradeGuard" -}}
{{- if not .Values.image.tag -}}
{{- $sts := lookup "apps/v1" "StatefulSet" .Release.Namespace (include "youtrack.fullname" .) -}}
{{- if $sts -}}
{{- $running := (index $sts.spec.template.spec.containers 0).image | splitList ":" | last -}}
{{- $parts := splitList "." $running -}}
{{- if and (ge (len $parts) 2) (regexMatch "^[0-9]+$" (index $parts 0)) (regexMatch "^[0-9]+$" (index $parts 1)) -}}
{{- if semverCompare "<2025.3.0" (printf "%s.%s.0" (index $parts 0) (index $parts 1)) -}}
{{- fail (printf "YouTrack %s cannot be upgraded to %s in one step: set image.tag to the next version of the upgrade path (see Upgrading in the chart README)" $running .Chart.AppVersion) -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}
