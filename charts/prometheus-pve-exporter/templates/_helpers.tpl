{{/*
Chart name, overridable with nameOverride.
*/}}
{{- define "prometheus-pve-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified app name: the release name alone when it already contains the
chart name. Truncated at 63 chars (DNS label limit).
*/}}
{{- define "prometheus-pve-exporter.fullname" -}}
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

{{- define "prometheus-pve-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Standard labels.
*/}}
{{- define "prometheus-pve-exporter.labels" -}}
helm.sh/chart: {{ include "prometheus-pve-exporter.chart" . }}
app.kubernetes.io/name: {{ include "prometheus-pve-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels: immutable on the Deployment, kept as in 1.x.
*/}}
{{- define "prometheus-pve-exporter.selectorLabels" -}}
app: {{ include "prometheus-pve-exporter.name" . }}
release: {{ .Release.Name }}
{{- end -}}

{{- define "prometheus-pve-exporter.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "prometheus-pve-exporter.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{- define "prometheus-pve-exporter.secretName" -}}
{{- .Values.pve.existingSecret | default (include "prometheus-pve-exporter.fullname" .) -}}
{{- end -}}

{{/*
Fail when the Ingress or the HTTPRoute has no host to route.
*/}}
{{- define "prometheus-pve-exporter.requireHostnames" -}}
{{- if not .Values.hostnames -}}
{{- fail "hostnames needs at least one host for the Ingress or the HTTPRoute" -}}
{{- end -}}
{{- end -}}
