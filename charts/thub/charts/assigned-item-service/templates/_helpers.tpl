{{/*
Expand the name of the chart.
*/}}
{{- define "assigned-item-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "assigned-item-service.fullname" -}}
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
{{- define "assigned-item-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "assigned-item-service.labels" -}}
helm.sh/chart: {{ include "assigned-item-service.chart" . }}
{{ include "assigned-item-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "assigned-item-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "assigned-item-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "assigned-item-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "assigned-item-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the Assigned Item Service application settings configmap
*/}}
{{- define "assigned-item-service.assignedItemServiceConfigmapName" -}}
{{ include "assigned-item-service.name" . }}-application-config
{{- end }}

{{/*
Create the name of the Grails datasource configmap
*/}}
{{- define "assigned-item-service.datasourceConfigmapName" -}}
{{ include "assigned-item-service.name" . }}-datasource-config
{{- end }}

{{/*
Create the name of the CronJob resubmit-ojts-scheduler-job
*/}}
{{- define "assigned-item-service.resubmitOjtsSchedulerJobName" -}}
{{ include "assigned-item-service.name" . }}-resubmit-ojts-scheduler-job
{{- end }}
