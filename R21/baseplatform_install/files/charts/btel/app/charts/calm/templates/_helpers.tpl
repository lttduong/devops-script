{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "alarm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "alarm.fullname" -}}
{{- $name := default .Chart.Name .Values.fullnameOverride -}}
{{- if empty .Values.global.podNamePrefix -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $prefix := trimSuffix "-" .Values.global.podNamePrefix -}}
{{- printf "%s-%s-%s" $prefix .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app container name.
It is required to prefix container separately.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "alarm.container.fullname" -}}
{{- $name := default .Chart.Name .Values.fullnameOverride -}}
{{- if empty .Values.global.containerNamePrefix -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $prefix := trimSuffix "-" .Values.global.containerNamePrefix -}}
{{- printf "%s-%s-%s" $prefix .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}