{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "schema-registry.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-sr-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "listeners" -}}
{{- $servicePort := .Values.servicePort  | toString }}
{{- if and (.Values.sr_ssl.enabled) (.Values.sr_ssl.http_listener.servicePort) -}}
{{- printf "https://0.0.0.0:%s,http://0.0.0.0:%s" $servicePort .Values.sr_ssl.http_listener.servicePort | toString }}
{{- else if .Values.sr_ssl.enabled -}}
{{- printf "https://0.0.0.0:%s" $servicePort }}
{{- else -}}
{{- printf "http://0.0.0.0:%s" $servicePort }}
{{- end -}}
{{- end -}}

{{- define "kafkastore-security-protocol" -}}
{{- if and (.Values.sasl.enable) (.Values.kafkastore_ssl.enabled) -}}
{{- printf "SASL_SSL" }}
{{- else if .Values.sasl.enable -}}
{{- printf "SASL_PLAINTEXT" }}
{{- else if .Values.kafkastore_ssl.enabled -}}
{{- printf "SSL" }}
{{- else -}}
{{- printf "PLAINTEXT" }}
{{- end -}}
{{- end -}}


{{/*
Default GroupId to Release Name but allow it to be overridden
*/}}
{{- define "schema-registry.groupId" -}}
{{- if .Values.overrideGroupId -}}
{{- .Values.overrideGroupId -}}
{{- else -}}
{{- .Release.Name -}}
{{- end -}}
{{- end -}}

{{/*
ingress host name configuration.
*/}}
{{- define "ingressHost.name" -}}
{{- if .Values.ingress.hostName -}}
{{- printf "%s" .Values.ingress.hostName }}
{{- else -}}
{{- printf "%s.%s.svc.cluster.local" ( include "schema-registry.name" . ) .Release.Namespace -}}
{{- end -}}
{{- end -}}
