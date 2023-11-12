{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "curator.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Custom modification for CSFS-31458 https://jiradc2.ext.net.nokia.com/browse/CSFS-31458
Create a default fully qualified app name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{/*
{{- define "curator.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}
*/}}

{{/*
Custom modification for CSFS-31458 https://jiradc2.ext.net.nokia.com/browse/CSFS-31458
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "curator.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
End custom modification
*/}}

{{/*
Define pod name prefix value
*/}}
{{- define "curator.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix  -}}
{{- end -}}
{{- end -}}

{{/*
Define container name prefix value
*/}}
{{- define "curator.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix  -}}
{{- end -}}
{{- end -}}

{{- define "curator.job.name" -}}
{{- printf "%s%s" (include "curator.podNamePrefix" .) ( include "curator.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "curator.container.name" -}}
{{- if .Values.customResourceNames.curatorCronJobPod.curatorContainerName -}}
{{- printf "%s%s" (include "curator.containerNamePrefix" .) .Values.customResourceNames.curatorCronJobPod.curatorContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%scurator" (include "curator.containerNamePrefix" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "curator.deleteJob.container.name" -}}
{{- if .Values.customResourceNames.deleteJob.deleteJobContainerName -}}
{{- printf "%s%s" (include "curator.containerNamePrefix" .) .Values.customResourceNames.deleteJob.deleteJobContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spost-delete-curator-jobs" (include "curator.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "curator.deleteJob.name" -}}
{{- if .Values.customResourceNames.deleteJob.name -}}
{{- printf "%s%s" (include "curator.podNamePrefix" .) .Values.customResourceNames.deleteJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-delete-curator-jobs" (include "curator.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/* Reference
https://confluence.app.alcatel-lucent.com/display/plateng/Helm+best+practices#Helmbestpractices-LabelsandAnnotations
*/}}
{{- define "curator.csf-toolkit-helm.annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "curator.custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}
