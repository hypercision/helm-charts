{{/*
Expand the name of the chart.
*/}}
{{- define "thub.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "thub.fullname" -}}
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
{{- define "thub.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "thub.labels" -}}
helm.sh/chart: {{ include "thub.chart" . }}
{{ include "thub.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "thub.selectorLabels" -}}
app.kubernetes.io/name: {{ include "thub.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "thub.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "thub.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the OJT job queue
*/}}
{{- define "thub.ojtJobQueueName" -}}
{{ .Release.Namespace }}-ojtJobQueue
{{- end }}

{{/*
Create the name of the LMS Data Service job queue
*/}}
{{- define "thub.sfLmsDataJobQueueName" -}}
{{ .Release.Namespace }}-sfLmsDataJobQueue
{{- end }}

{{/*
Create the contents of the Grails JMS properties file configmap
*/}}
{{- define "thub.grailsAppConfigmapPropertiesFile" -}}
jms.destinations.assignedItemQueue={{ .Release.Namespace }}-assignedItemQueue
jms.destinations.assignedItemOjtCreationQueue={{ .Release.Namespace }}-assignedItemOjtCreationQueue
jms.destinations.assignedItemOjtCreationResultsQueue={{ .Release.Namespace }}-assignedItemOjtCreationResultsQueue
jms.destinations.completionStatusQueue={{ .Release.Namespace }}-completionStatusQueue
jms.destinations.instructorQueue={{ .Release.Namespace }}-instructorQueue
jms.destinations.itemQueue={{ .Release.Namespace }}-itemQueue
jms.destinations.learnerQueue={{ .Release.Namespace }}-learnerQueue
jms.destinations.ojtJobQueue={{ include "thub.ojtJobQueueName" . }}
jms.destinations.sfLmsDataJobQueue={{ include "thub.sfLmsDataJobQueueName" . }}
{{- end }}

{{/*
Default tag to use for the 342628741687.dkr.ecr.us-west-2.amazonaws.com/thub-event-scheduler-job
Docker image
*/}}
{{- define "thub.eventSchedulerJobTag" -}}
v1.1.1
{{- end }}
