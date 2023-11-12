{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 40 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "zookeeper.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-zk-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "zk-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "zookeeper.namespace" -}}
{{- printf "%s" .Release.Namespace }}
{{- end -}}

{{- define "zkserviceAccount.name" }}
      {{- if .Values.global.rbacEnable }}
      {{- if .Values.global.serviceAccountName }}
        {{ .Values.global.serviceAccountName }}
      {{- else -}}
        {{ template "zookeeper.name" . }}-zkadmin
      {{- end }}
      {{- end }}
{{- end -}}

