{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-ui.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka-ui.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kafka-ui.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-ui.labels" -}}
helm.sh/chart: {{ include "kafka-ui.chart" . }}
{{ include "kafka-ui.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-ui.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-ui.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "kafka-ui.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafka-ui.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafka-ui.fullname" .) .Values.serviceAccount.name }}-serviceaccount
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service to use
*/}}
{{- define "kafka-ui.serviceName" -}}
{{ include "kafka-ui.fullname" . }}-service
{{- end }}

{{/*
Define name for configMap
*/}}
{{- define "kafka-ui.configMapName" -}}
{{ include "kafka-ui.fullname" . }}-configmap
{{- end }}