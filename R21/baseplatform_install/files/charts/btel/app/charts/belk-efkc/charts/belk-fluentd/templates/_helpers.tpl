{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fluentd.name" -}}
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
{{- define "fluentd.fullname" -}}
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
{{- define "fluentd.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
End custom modification
*/}}

{{/*
Define pod name prefix value
*/}}
{{- define "fluentd.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix  -}}
{{- end -}}
{{- end -}}

{{/*
Define container name prefix value
*/}}
{{- define "fluentd.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix  -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.deployment.name" -}}
{{- printf "%s%s"  (include "fluentd.podNamePrefix" .) (include "fluentd.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "fluentd.daemonset.name" -}}
{{- printf "%s%s%s"  (include "fluentd.podNamePrefix" .) (include "fluentd.fullname" .) .Values.fluentd.daemonsetSuffix  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "fluentd.statefulset.name" -}}
{{- printf "%s%s%s"  (include "fluentd.podNamePrefix" .) (include "fluentd.fullname" .) .Values.fluentd.statefulsetSuffix  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "fluentd.deletePvcJob.name" -}}
{{- if .Values.customResourceNames.deletePvcJob.name -}}
{{- printf "%s%s" (include "fluentd.podNamePrefix" .) .Values.customResourceNames.deletePvcJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-delete-pvc-job" (include "fluentd.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.scaleInJob.name" -}}
{{- if .Values.customResourceNames.scaleinJob.name -}}
{{- printf "%s%s" (include "fluentd.podNamePrefix" .) .Values.customResourceNames.scaleinJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-postscalein" (include "fluentd.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.daemonset.container" -}}
{{- if .Values.customResourceNames.fluentdPod.fluentdContainerName -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) .Values.customResourceNames.fluentdPod.fluentdContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s%s" (include "fluentd.containerNamePrefix" .) (include "fluentd.fullname" .) .Values.fluentd.daemonsetSuffix | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.deployment.container" -}}
{{- if .Values.customResourceNames.fluentdPod.fluentdContainerName -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) .Values.customResourceNames.fluentdPod.fluentdContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) (include "fluentd.fullname" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.statefulset.container" -}}
{{- if .Values.customResourceNames.fluentdPod.fluentdContainerName -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) .Values.customResourceNames.fluentdPod.fluentdContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s%s" (include "fluentd.containerNamePrefix" .) (include "fluentd.fullname" .) .Values.fluentd.statefulsetSuffix | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.scaleInContainer.name" -}}
{{- if .Values.customResourceNames.scaleinJob.postscaleinContainerName -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) .Values.customResourceNames.scaleinJob.postscaleinContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spostscalein" (include "fluentd.containerNamePrefix" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "fluentd.deletePvcContainer.name" -}}
{{- if .Values.customResourceNames.deletePvcJob.deletePvcContainerName -}}
{{- printf "%s%s" (include "fluentd.containerNamePrefix" .) .Values.customResourceNames.deletePvcJob.deletePvcContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spost-delete-pvc" (include "fluentd.containerNamePrefix" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Reference
https://confluence.app.alcatel-lucent.com/display/plateng/Helm+best+practices#Helmbestpractices-LabelsandAnnotations
*/}}
{{- define "fluentd.csf-toolkit-helm.annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "fluentd.custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "fluentd.istio.initIstio" -}}
{{- $_ := set . "istioVersion" (default (.Values.global.istio.version) .Values.istio.version) }}
{{- end }}
