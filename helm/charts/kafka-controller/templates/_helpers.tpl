{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka-controller.fullname" -}}
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
{{- define "kafka-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-controller.labels" -}}
helm.sh/chart: {{ include "kafka-controller.chart" . }}
{{ include "kafka-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "kafka-controller.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafka-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafka-controller.fullname" .) .Values.serviceAccount.name }}-serviceaccount
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service to use
*/}}
{{- define "kafka-controller.serviceName" -}}
{{ include "kafka-controller.fullname" . }}-service
{{- end }}

{{/*
Define name for configMap
*/}}
{{- define "kafka-controller.configMapName" -}}
{{ include "kafka-controller.fullname" . }}-configmap
{{- end }}

{{/*
Define name for headless service
*/}}
{{- define "kafka-controller.headlessServiceName" -}}
{{ include "kafka-controller.fullname" . }}-headless
{{- end }}