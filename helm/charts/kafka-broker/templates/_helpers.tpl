{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-broker.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kafka-broker.fullname" -}}
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
{{- define "kafka-broker.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kafka-broker.labels" -}}
helm.sh/chart: {{ include "kafka-broker.chart" . }}
{{ include "kafka-broker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kafka-broker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kafka-broker.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ include "kafka-broker.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "kafka-broker.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kafka-broker.fullname" .) .Values.serviceAccount.name }}-serviceaccount
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the service to use - CAN BE REMOVED, USE HEADLESS SERVICE INSTEAD
*/}}
{{- define "kafka-broker.serviceName" -}}
{{ include "kafka-broker.fullname" . }}-service
{{- end }}

{{/*
Define name for configMap
*/}}
{{- define "kafka-broker.configMapName" -}}
{{ include "kafka-broker.fullname" . }}-configmap
{{- end }}

{{/*
Define name for headless service
*/}}
{{- define "kafka-broker.headlessServiceName" -}}
{{ include "kafka-broker.fullname" . }}-headless
{{- end }}

{{/*
Define kafka controller name for headless service
*/}}
{{- define "kafka-controller.headlessServiceName" -}}
{{ default  "kafka-controller-headless" }}
{{- end }}

{{/*
Define kafka controller name for fullname
*/}}
{{- define "kafka-controller.fullname" -}}
{{ default  "kafka-controller" }}
{{- end }}