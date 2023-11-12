{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cnot.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cnot.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the alertmanager component
*/}}

{{- define "cnot.serviceAccountName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- $serviceaccountname := printf "%s-%s-%s" .Release.Name $name "serviceaccount" -}}
{{- default $serviceaccountname .Values.serviceAccountName  | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cnot.podSecurityPolicyName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "psp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

## logFileSize and numOfLogFiles values can be provisioned from values.yaml OR by modifying config map "<releasename>-wildfly-hook"
{{- define "wildfly.logFileSize" -}}
{{- default .Values.wildfly.logFileSize | default "5m" | quote }}
{{- end -}}

{{- define "wildfly.numOfLogFiles" -}}
{{- default .Values.wildfly.numOfLogFiles | default "5" | quote }}
{{- end -}}
