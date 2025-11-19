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
Create the OJT Server URL / Ingress path
*/}}
{{- define "thub.ojtServerUrl" -}}
{{- if and .Values.global.ingress.enabled .Values.global.ingress.ojtUrlPrefix -}}
{{ print .Values.global.ingress.ojtUrlPrefix "." .Values.global.ingress.domain }}
{{- else if .Values.global.ingress.enabled -}}
{{ print "ojt-" .Release.Namespace "." .Values.global.ingress.domain }}
{{- end }}
{{- end }}

{{/*
Create the OJT Server URL / Ingress path Environment Variable
*/}}
{{- define "thub.ojtServerUrlEnv" -}}
{{- if .Values.global.ingress.enabled -}}
- name: grails.serverURL
  value: {{ print "https://" (include "thub.ojtServerUrl" .) | quote }}
{{- end }}
{{- end }}

{{/*
Create the LMS Data Service Server URL / Ingress path
*/}}
{{- define "thub.lmsDataServiceServerUrl" -}}
{{- if .Values.global.ingress.enabled -}}
{{ print "dataorchestration-" .Release.Namespace "." .Values.global.ingress.domain }}
{{- end }}
{{- end }}

{{/*
Create the LMS Data Service Server URL / Ingress path Environment Variable
*/}}
{{- define "thub.lmsDataServiceServerUrlEnv" -}}
{{- if .Values.global.ingress.enabled -}}
- name: grails.serverURL
  value: {{ print "https://" (include "thub.lmsDataServiceServerUrl" .) | quote }}
{{- end }}
{{- end }}

{{/*
Create the contents of the Grails JMS properties file configmap
*/}}
{{- define "thub.grailsAppConfigmapPropertiesFile" -}}
jms.destinations.assignedItemQueue={{ .Release.Namespace }}-assignedItemQueue
jms.destinations.assignedItemOjtCreationQueue={{ .Release.Namespace }}-assignedItemOjtCreationQueue
jms.destinations.assignedItemOjtCreationResultsQueue={{ .Release.Namespace }}-assignedItemOjtCreationResultsQueue
jms.destinations.attendeeRegistrationQueue={{ .Release.Namespace }}-attendeeRegistrationQueue
jms.destinations.completionStatusQueue={{ .Release.Namespace }}-completionStatusQueue
jms.destinations.createCourseOfferingQueue={{ .Release.Namespace }}-createCourseOfferingQueue
jms.destinations.createCourseOfferingResultsQueue={{ .Release.Namespace }}-createCourseOfferingResultsQueue
jms.destinations.instructorQueue={{ .Release.Namespace }}-instructorQueue
jms.destinations.itemQueue={{ .Release.Namespace }}-itemQueue
jms.destinations.learnerQueue={{ .Release.Namespace }}-learnerQueue
jms.destinations.managerQueue={{ .Release.Namespace }}-managerQueue
jms.destinations.ojtJobQueue={{ include "thub.ojtJobQueueName" . }}
jms.destinations.sfLmsDataJobQueue={{ include "thub.sfLmsDataJobQueueName" . }}
jms.destinations.scheduledOfferingQueue={{ .Release.Namespace }}-scheduledOfferingQueue
{{- end }}

{{/*
Default tag to use for the 342628741687.dkr.ecr.us-west-2.amazonaws.com/thub-event-scheduler-cli-job
Docker image
*/}}
{{- define "thub.eventSchedulerJobTag" -}}
v2.0.4
{{- end }}
