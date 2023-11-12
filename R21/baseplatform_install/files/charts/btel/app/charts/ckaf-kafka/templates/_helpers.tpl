{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 40 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "kafka.name" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.nameOverride -}}
{{- printf "ckaf-kf-%s" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "kf-%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{- define "zkConnect.url" }}
{{- if index .Values "ckaf-zookeeper" "enabled" -}}

{{- if index .Values "ckaf-zookeeper" "fullnameOverride" -}}
    {{- $rlsname := index .Values "ckaf-zookeeper" "fullnameOverride" -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "clientPort" | toString -}}
        {{ $rlsname }}.{{ $namespace }}.svc.cluster.local:{{ $port }}
{{- else if index .Values "ckaf-zookeeper" "nameOverride" -}}
    {{- $rlsname := index .Values "ckaf-zookeeper" "nameOverride" -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "clientPort" | toString -}}
        ckaf-zk-{{ $rlsname }}.{{ $namespace }}.svc.cluster.local:{{ $port }}
{{- else -}}
    {{- $rlsname := .Release.Name -}}
    {{- $namespace := .Release.Namespace -}}
    {{- $port := index .Values "ckaf-zookeeper" "clientPort" | toString -}}
        zk-{{ $rlsname }}.{{ $namespace }}.svc.cluster.local:{{ $port }}
{{- end -}}

 {{- else -}}
    {{- printf "%s" .Values.zkConnect }}
{{- end -}}
{{- end -}}


{{- define "kfserviceAccount.name" }}
      {{- if .Values.global.rbacEnable }}
      {{- if .Values.global.serviceAccountName }}
        {{ .Values.global.serviceAccountName }}
      {{- else -}}
        {{ template "kafka.name" . }}-kfadmin
      {{- end }}
      {{- end }}
{{- end -}}

{{- define "kafka.namespace" -}}
{{- printf "%s" .Release.Namespace }}
{{- end -}}
