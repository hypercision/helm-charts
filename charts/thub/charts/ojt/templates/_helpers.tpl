{{/*
Expand the name of the chart.
*/}}
{{- define "ojt.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ojt.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ojt.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ojt.labels" -}}
helm.sh/chart: {{ include "ojt.chart" . }}
{{ include "ojt.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ojt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ojt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ojt.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ojt.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the Grails datasource configmap
*/}}
{{- define "ojt.datasourceConfigmapName" -}}
{{ include "ojt.name" . }}-datasource-config
{{- end }}

{{/*
Create the name of the OJT application settings configmap
*/}}
{{- define "ojt.ojtConfigmapName" -}}
{{ include "ojt.name" . }}-ojt-app-settings-config
{{- end }}

{{/*
Create the name of the CronJob learning-history-scheduler-job
*/}}
{{- define "ojt.learningHistorySchedulerJobName" -}}
{{ include "ojt.name" . }}-learning-history-scheduler-job
{{- end }}
