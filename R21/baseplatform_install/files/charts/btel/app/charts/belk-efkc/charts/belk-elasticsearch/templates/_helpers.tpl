{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "elasticsearch.name" -}}
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
{{- define "elasticsearch.fullname" -}}
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
{{- define "elasticsearch.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
End custom modification
*/}}

{{/*
Define pod name prefix value
*/}}
{{- define "elasticsearch.podNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.podNamePrefix  -}}
{{- end -}}
{{- end -}}


{{/*
Define container name prefix value
*/}}
{{- define "elasticsearch.containerNamePrefix" -}}
{{- if or (.Values.fullnameOverride) (.Values.nameOverride)  -}}
{{- printf "" -}}
{{- else -}}
{{- default "" .Values.global.containerNamePrefix  -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified master name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "elasticsearch.master.fullname" -}}
{{- printf "%s%s-%s" (include "elasticsearch.podNamePrefix" .) ( include "elasticsearch.fullname" .) .Values.elasticsearch_master.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified client name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "elasticsearch.client.fullname" -}}
{{- printf "%s%s-%s" (include "elasticsearch.podNamePrefix" .) ( include "elasticsearch.fullname" .) .Values.elasticsearch_client.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified data name.
we truncate based on user configurable parameter "customResourceNames.resourceNameLimit", by default this is set to 63 which is the limit set by DNS naming spec for some Kubernetes name fields.
*/}}
{{- define "elasticsearch.data.fullname" -}}
{{- printf "%s%s-%s" (include "elasticsearch.podNamePrefix" .) ( include "elasticsearch.fullname" .) .Values.esdata.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}

{{- define "elasticsearch.endpoints" -}}
{{- $replicas := .Values.elasticsearch_master.replicas | int }}
{{- $esmaster := printf "%s%s-%s" (include "elasticsearch.podNamePrefix" .) (include "elasticsearch.fullname" .) .Values.elasticsearch_master.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-"}}
  {{- range $i, $e := untilStep 0 $replicas 1 -}}
{{ $esmaster }}-{{ $i }},
  {{- end }}
{{- end }}

{{- define "es.delete.preHealJob.name" -}}
{{- if .Values.customResourceNames.postDeletePrehealJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.postDeletePrehealJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-delete-prehealjob" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.delete.pvcJob.name" -}}
{{- if .Values.customResourceNames.postDeletePvcJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.postDeletePvcJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-delete-pvc-job" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.delete.cleanUpJob.name" -}}
{{- if .Values.customResourceNames.postDeleteCleanupJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.postDeleteCleanupJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-cleanup-job" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.preHealJob.name" -}}
{{- if .Values.customResourceNames.preHealJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.preHealJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-preheal" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.postScaleInJob.name" -}}
{{- if .Values.customResourceNames.postScaleInJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.postScaleInJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-es-postscalein" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.preUpgradeJob.name" -}}
{{- if .Values.customResourceNames.preUpgradeSgMigrateJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.preUpgradeSgMigrateJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-preupgrade-sg-job" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.postUpgradejob.name" -}}
{{- if .Values.customResourceNames.postUpgradeSgMigrateJob.name -}}
{{- printf "%s%s" (include "elasticsearch.podNamePrefix" .) .Values.customResourceNames.postUpgradeSgMigrateJob.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s%s-postupgrade-sg-job" (include "elasticsearch.podNamePrefix" .) .Release.Name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.delete.preHealContainer.name" -}}
{{- if .Values.customResourceNames.postDeletePrehealJob.postDeletePrehealContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.postDeletePrehealJob.postDeletePrehealContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spost-delete-prehealjob" (include "elasticsearch.containerNamePrefix" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.delete.pvcContainer.name" -}}
{{- if .Values.customResourceNames.postDeletePvcJob.postDeletePvcContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.postDeletePvcJob.postDeletePvcContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spost-delete-pvc" (include "elasticsearch.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.delete.cleanUpContainer.name" -}}
{{- if .Values.customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.postDeleteCleanupJob.postDeleteCleanupContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spost-delete-cleanup" (include "elasticsearch.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.preUpgradeSgMigrateContainer.name" -}}
{{- if .Values.customResourceNames.preUpgradeSgMigrateJob.preUpgradeSgMigrateContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.preUpgradeSgMigrateJob.preUpgradeSgMigrateContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%supgrade-sg-job" (include "elasticsearch.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.postUpgradeSgMigrateContainer.name" -}}
{{- if .Values.customResourceNames.postUpgradeSgMigrateJob.postUpgradeSgMigrateContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.postUpgradeSgMigrateJob.postUpgradeSgMigrateContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%supgrade-sg-job" (include "elasticsearch.containerNamePrefix" .) | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.preHealContainer.name" -}}
{{- if .Values.customResourceNames.preHealJob.preHealContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.preHealJob.preHealContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spreheal" (include "elasticsearch.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "es.postScaleInContainer.name" -}}
{{- if .Values.customResourceNames.postScaleInJob.postScaleInContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.postScaleInJob.postScaleInContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%spostscalein" (include "elasticsearch.containerNamePrefix" .)  | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.client.container" -}}
{{- if .Values.customResourceNames.clientPod.clientContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.clientPod.clientContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%ses-%s" (include "elasticsearch.containerNamePrefix" .)  .Values.elasticsearch_client.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.data.container" -}}
{{- if .Values.customResourceNames.dataPod.dataContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.dataPod.dataContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%ses-%s" (include "elasticsearch.containerNamePrefix" .)  .Values.esdata.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.master.container" -}}
{{- if .Values.customResourceNames.masterPod.masterContainerName -}}
{{- printf "%s%s" (include "elasticsearch.containerNamePrefix" .) .Values.customResourceNames.masterPod.masterContainerName | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- else -}}
{{- printf "%ses-%s" (include "elasticsearch.containerNamePrefix" .)  .Values.elasticsearch_master.name | trunc (.Values.customResourceNames.resourceNameLimit | int ) | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.esciphers" -}}
{{- join "," .Values.searchguard.ciphers }}
{{- end -}}

{{/* Reference
https://confluence.app.alcatel-lucent.com/display/plateng/Helm+best+practices#Helmbestpractices-LabelsandAnnotations
*/}}
{{- define "elasticsearch.csf-toolkit-helm.annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{- define "elasticsearch.istio.initIstio" -}}
{{- $_ := set . "istioVersion" (default (.Values.global.istio.version) .Values.istio.version) }}
{{- end }}
