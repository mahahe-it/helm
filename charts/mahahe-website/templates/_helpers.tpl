{{/*
Chart name, overridable with nameOverride.
*/}}
{{- define "mahahe-website.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified app name: the release name alone when it already contains the
chart name. Truncated at 63 chars (DNS label limit).
*/}}
{{- define "mahahe-website.fullname" -}}
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

{{- define "mahahe-website.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mahahe-website.labels" -}}
helm.sh/chart: {{ include "mahahe-website.chart" . }}
{{ include "mahahe-website.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "mahahe-website.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mahahe-website.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
