{{/*
Expand the name of the chart.
*/}}
{{- define "lms-data-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lms-data-service.fullname" -}}
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
{{- define "lms-data-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lms-data-service.labels" -}}
helm.sh/chart: {{ include "lms-data-service.chart" . }}
{{ include "lms-data-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lms-data-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lms-data-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lms-data-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lms-data-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the Grails datasource configmap
*/}}
{{- define "lms-data-service.datasourceConfigmapName" -}}
{{ include "lms-data-service.name" . }}-datasource-config
{{- end }}

{{/*
Create the name of the encryption configmap
*/}}
{{- define "lms-data-service.encryptionConfigmapName" -}}
{{ include "lms-data-service.name" . }}-encryption-config
{{- end }}

{{/*
Create the name of the SFTP configmap
*/}}
{{- define "lms-data-service.sftpConfigmapName" -}}
{{ include "lms-data-service.name" . }}-sftp-config
{{- end }}

{{/*
Create the name of the Webservice configmap
*/}}
{{- define "lms-data-service.webserviceConfigmapName" -}}
{{ include "lms-data-service.name" . }}-webservice-config
{{- end }}

{{/*
Create the name of the Workday setup configmap
*/}}
{{- define "lms-data-service.workdayConfigmapName" -}}
{{ include "lms-data-service.name" . }}-workday-config
{{- end }}

{{/*
Create the name of the thub-event-scheduler-job input files configmap
*/}}
{{- define "lms-data-service.eventSchedulerInputFilesConfigmapName" -}}
{{ include "lms-data-service.name" . }}-event-scheduler-job-input-files
{{- end }}

{{/*
Create the name of the CronJob assigned-items-scheduler-job
*/}}
{{- define "lms-data-service.assignedItemsSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-assigned-items-scheduler-job
{{- end }}

{{/*
Create the name of the JSON file used by the assigned-items-scheduler-job
*/}}
{{- define "lms-data-service.assignedItemsSchedulerJobInputFile" -}}
{{- if .Values.assignedItemsSchedulerJob.jsonInputFile -}}
{{ print .Values.assignedItemsSchedulerJob.jsonInputFile }}
{{- else -}}
{{ print "./temp/start-assigned-items-job.json" }}
{{- end }}
{{- end }}

{{/*
Create the name of the CronJob lms-end-incomplete-jobs-scheduler-job
*/}}
{{- define "lms-data-service.endIncompleteJobsSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-end-incomplete-jobs-scheduler-job
{{- end }}

{{/*
Create the name of the CronJob instructors-scheduler-job
*/}}
{{- define "lms-data-service.instructorsSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-instructors-scheduler-job
{{- end }}

{{/*
Create the name of the JSON file used by the instructors-scheduler-job
*/}}
{{- define "lms-data-service.instructorsSchedulerJobInputFile" -}}
{{- if .Values.instructorsSchedulerJob.jsonInputFile -}}
{{ print .Values.instructorsSchedulerJob.jsonInputFile }}
{{- else if eq .Values.global.lmsType "WORKDAY" -}}
{{ print "./temp/start-instructors-web-job.json" }}
{{- else -}}
{{ print "./temp/start-instructors-job.json" }}
{{- end }}
{{- end }}

{{/*
Create the name of the CronJob items-scheduler-job
*/}}
{{- define "lms-data-service.itemsSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-items-scheduler-job
{{- end }}

{{/*
Create the name of the JSON file used by the items-scheduler-job
*/}}
{{- define "lms-data-service.itemsSchedulerJobInputFile" -}}
{{- if .Values.itemsSchedulerJob.jsonInputFile -}}
{{ print .Values.itemsSchedulerJob.jsonInputFile }}
{{- else if eq .Values.global.lmsType "WORKDAY" -}}
{{ print "./temp/start-items-web-job.json" }}
{{- else -}}
{{ print "./temp/start-items-job.json" }}
{{- end }}
{{- end }}

{{/*
Create the name of the CronJob items-inactive-scheduler-job
*/}}
{{- define "lms-data-service.itemsInactiveSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-items-inactive-scheduler-job
{{- end }}

{{/*
Create the name of the JSON file used by the items-inactive-scheduler-job
*/}}
{{- define "lms-data-service.itemsInactiveSchedulerJobInputFile" -}}
{{- if .Values.itemsInactiveSchedulerJob.jsonInputFile -}}
{{ print .Values.itemsInactiveSchedulerJob.jsonInputFile }}
{{- else if eq .Values.global.lmsType "WORKDAY" -}}
{{ print "./temp/start-items-inactive-web-job.json" }}
{{- else -}}
{{ print "./temp/start-items-inactive-job.json" }}
{{- end }}
{{- end }}

{{/*
Create the name of the CronJob learners-scheduler-job
*/}}
{{- define "lms-data-service.learnersSchedulerJobName" -}}
{{ include "lms-data-service.name" . }}-learners-scheduler-job
{{- end }}

{{/*
Create the name of the JSON file used by the learners-scheduler-job
*/}}
{{- define "lms-data-service.learnersSchedulerJobInputFile" -}}
{{- if .Values.learnersSchedulerJob.jsonInputFile -}}
{{ print .Values.learnersSchedulerJob.jsonInputFile }}
{{- else if eq .Values.global.lmsType "WORKDAY" -}}
{{ print "./temp/start-learners-web-job.json" }}
{{- else -}}
{{ print "./temp/start-learners-job.json" }}
{{- end }}
{{- end }}

{{/*
Create the name of the JSON file used by the learning-history-upload-job
*/}}
{{- define "lms-data-service.learningHistoryUploadJobInputFile" -}}
{{- if .Values.learningHistoryUploadJob.jsonInputFile -}}
{{ print .Values.learningHistoryUploadJob.jsonInputFile }}
{{- else -}}
{{ print "./temp/start-lms-learning-history-job.json" }}
{{- end }}
{{- end }}
