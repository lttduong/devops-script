{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "gen3gppxml.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "gen3gppxml.fullname" -}}
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
Return the appropriate apiVersion for apps/v1beta1.
*/}}
{{- define "prometheus.apiVersionAppsV1Beta1orV1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the components labels
*/}}
{{- define "custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the components annotations
*/}}
{{- define "custom-annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the gen3gpp component resource labels
*/}}
{{- define "gen3gpp-labels" -}}
{{- $gen3gpp_labels := index . 0 -}}
{{- range $key, $value :=  $gen3gpp_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the gen3gpp component resource annotations
*/}}
{{- define "gen3gpp-annotations" -}}
{{- $gen3gpp_annotations := index . 0 -}}
{{- range $key, $value :=  $gen3gpp_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for podsecuritypolicy.
*/}}
{{- define "gen3gpp.apiVersionExtensionsV1Beta1orPolicyV1Beta1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the gen3gppxml component
*/}}
{{- define "gen3gpp.serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
    {{- print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- printf "%s-%s" (include "gen3gppxml.fullname" .) "service-account" -}}
{{- else -}}
    {{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Return the gen3gppxml statefulset name 
*/}}
{{- define "gen3gppxml.stsName" -}}
{{- if or (.Values.nameOverride) (.Values.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "gen3gppxml.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.gen3gppxmlPod.name | default (include "gen3gppxml.fullname" .) -}}
{{ template "gen3gppxml.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}


{{/*
Return the  gen3gppxml gen3gppxmlContainer name
*/}}
{{- define "gen3gppxml.gen3gppxmlContainer" -}}
{{- $name := printf "%s" "gen3gppxml"  -}}
{{- if ne .Values.customResourceNames.gen3gppxmlPod.gen3gppxmlContainer "" }}
{{- $name = .Values.customResourceNames.gen3gppxmlPod.gen3gppxmlContainer -}}
{{- end -}}
{{ template "gen3gppxml.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the  gen3gppxml sftpContainer name
*/}}
{{- define "gen3gppxml.sftpContainer" -}}
{{- $name := printf "%s" "sftp"  -}}
{{- if ne .Values.customResourceNames.gen3gppxmlPod.sftpContainer "" }}
{{- $name = .Values.customResourceNames.gen3gppxmlPod.sftpContainer -}}
{{- end -}}
{{ template "gen3gppxml.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the  gen3gppxml configMapReloadContainer name
*/}}
{{- define "gen3gppxml.configMapReloadContainer" -}}
{{- $name := printf "%s" "reload"  -}}
{{- if ne .Values.customResourceNames.gen3gppxmlPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.gen3gppxmlPod.configMapReloadContainer -}}
{{- end -}}
{{ template "gen3gppxml.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the gen3gppxml postDeletejobPod name 
*/}}
{{- define "gen3gppxml.postDeleteJobPod" -}}
{{- $name := printf "%s-%s" (include "gen3gppxml.fullname" .) "delete-pvc-job"  -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.name "" }}
{{- $name = .Values.customResourceNames.postDeleteJobPod.name -}}
{{- end -}}
{{ template "gen3gppxml.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the  gen3gppxml postDeletePvcContainer name
*/}}
{{- define "gen3gppxml.postDeletePvcContainer" -}}
{{- $name := printf "%s" "post-delete-pvc"  -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.postDeletePvcContainer "" }}
{{- $name = .Values.customResourceNames.postDeleteJobPod.postDeletePvcContainer -}}
{{- end -}}
{{ template "gen3gppxml.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}



{{- define "gen3gppxml.finalPodName" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.podNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}

{{- define "gen3gppxml.finalContainerName" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.containerNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalConName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalConName -}}
{{- end -}}
