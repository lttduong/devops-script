{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kibana.name" -}}
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
{{- define "kibana.fullname" -}}
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
{{- define "kibana.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
End custom modification
*/}}

{{/*
Define pod name prefix value
*/}}
{{- define "kibana.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix  -}}
{{- end -}}
{{- end -}}

{{/*
Define container name prefix value
*/}}
{{- define "kibana.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix  -}}
{{- end -}}
{{- end -}}

{{- define "kibana.deployment.name" -}}
{{- printf "%s%s" (include "kibana.podNamePrefix" .) (include "kibana.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "kibana.container.name" -}}
{{- if .Values.customResourceNames.kibanaPod.kibanaContainerName -}}
{{- printf "%s%s" (include "kibana.containerNamePrefix" .) .Values.customResourceNames.kibanaPod.kibanaContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "kibana.containerNamePrefix" .) (include "kibana.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Reference
https://confluence.app.alcatel-lucent.com/display/plateng/Helm+best+practices#Helmbestpractices-LabelsandAnnotations
*/}}
{{- define "kibana.csf-toolkit-helm.annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "kibana.custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "kibana.istio.initIstio" -}}
{{- $_ := set . "istioVersion" (default (.Values.global.istio.version) .Values.istio.version) }}
{{- end }}
{{/*
Return the appropriate apiVersion for serviceEntry and virtual svc
*/}}
{{- define "kibana.apiVersionNetworkIstioV1Alpha3orV1Beta1" -}}
{{- include "kibana.istio.initIstio" . }}
{{- if eq $.istioVersion 1.4 -}}
{{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
{{- print "networking.istio.io/v1beta1" -}}
{{- end -}}
{{- end -}}
