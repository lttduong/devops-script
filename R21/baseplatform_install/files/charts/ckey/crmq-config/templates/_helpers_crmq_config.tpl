{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "config.crmq.name" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "config.crmq.adminConfigFile" -}}
{{- printf "%s-%s" .Release.Name "admin-config" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "config.crmq.adminCommandsFile" -}}
{{- printf "%s-%s" .Release.Name "admin-commands" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "config.crmq.controlCommandsFile" -}}
{{- printf "%s-%s" .Release.Name "control-commands" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
