{{/*
Expand the name of the chart.
*/}}
{{- define "ms-cp-kafka.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ms-cp-kafka.fullname" -}}
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
{{- define "ms-cp-kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ms-cp-kafka.labels" -}}
helm.sh/chart: {{ include "ms-cp-kafka.chart" . }}
{{ include "ms-cp-kafka.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ms-cp-kafka.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ms-cp-kafka.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "ms-cp-kafka.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ms-cp-kafka.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ms-cp-kafka.fullname" .) .Values.serviceAccount.name }}-serviceaccount
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service to use
*/}}
{{- define "ms-cp-kafka.serviceName" -}}
{{ include "ms-cp-kafka.fullname" . }}-service
{{- end }}

{{/*
Define name for configMap
*/}}
{{- define "ms-cp-kafka.configMapName" -}}
{{ include "ms-cp-kafka.fullname" . }}-configmap
{{- end }}

{{/*
Define name for headless service
*/}}
{{- define "ms-cp-kafka.headlessServiceName" -}}
{{ include "ms-cp-kafka.fullname" . }}-headless
{{- end }}