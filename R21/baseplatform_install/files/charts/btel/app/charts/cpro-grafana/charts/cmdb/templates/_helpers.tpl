{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "cmdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cmdb.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "cmdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a pod prefix which includes an optional podNamePrefix + cmdb.fullname
Used in StatefulSets admin/mariadb/maxscale (which add up to 8 characters)
*/}}
{{- define "cmdb.pod-prefix" -}}
{{- printf "%s%s" (default "" .Values.global.podNamePrefix) (include "cmdb.fullname" .) | trunc 55 -}}
{{- end -}}

{{/*
Create a container prefix which includes an optional containerNamePrefix
*/}}
{{- define "cmdb.container-prefix" -}}
{{- default "" .Values.global.containerNamePrefix -}}
{{- end -}}

{{/*
Create a job name in form <cmdb.pod-prefix><.Hook.name>
Arguments:
  Values    - .Values
  Chart     - .Chart
  Release   - .Release
  Hook      - .Values.hooks.<job>
  HookType  - hook type (pre/post)
*/}}
{{- define "cmdb-job.name" -}}
{{- printf "%s-%s" (include "cmdb.pod-prefix" .) .Hook.name | trunc 50 -}}
{{- end -}}

{{/*
Create a job container name which includes an optional containerNamePrefix
Arguments:
  Values    - .Values
  Chart     - .Chart
  Release   - .Release
  Hook      - .Values.hooks.<job>
  HookType  - hook type (pre/post)
*/}}
{{- define "cmdb-job.container-name" -}}
{{- printf "%s%s" (include "cmdb.container-prefix" .) .Hook.containerName -}}
{{- end -}}

{{/*
Standard CMDB kubernetes (k8s) job environment
Arguments:
  Values    - .Values
  Chart     - .Chart
  Release   - .Release
  Hook      - .Values.hooks.<job>
  HookType  - hook type (pre/post)
*/}}
{{- define "cmdb-job.env" -}}
- name: HOOK_TYPE
  value: {{ .HookType }}
{{- if gt (int .Hook.timeout) 0 }}
- name: HOOK_TIMEOUT
  value: "{{ .Hook.timeout }}"
{{- end }}
{{- if and .Values.admin.debug (gt (int (default '0' .Values.hooks.jobDelay)) 0) }}
- name: HOOK_DELAY
  value: "{{ .Values.hooks.jobDelay }}"
{{- end }}
{{- end -}}

{{/*
Admin service name for all pods to be able to talk to Admin DB.
*/}}
{{- define "cmdb-admin.service" -}}
{{- if ne (.Values.cluster_type) "simplex" }}
- name: ADMIN_SERVICE_NAME
  value: "{{- default (printf "%s-admin" (include "cmdb.fullname" .)) .Values.services.admin.name }}"
- name: ADMIN_DB_AUTH
  valueFrom:
    secretKeyRef:
      name: {{ template "cmdb.fullname" . }}-admin-secrets
      key: redis-password
      optional: true
{{- end -}}
{{- end -}}

{{/*
Admin pod security context
*/}}
{{- define "cmdb-admin.secctx" -}}
securityContext:
  runAsUser: 1773
  runAsGroup: 1773
  fsGroup: 1773
{{- end }}

{{/*
* Determine the serviceAccountNames
*/}}
{{- define "cmdb.sa" -}}
{{- if .Values.rbac_enabled }}
serviceAccountName: {{ default ( include "cmdb.fullname" . ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- end }}
{{- end }}
{{- define "cmdb.le-sa" -}}
{{- if .Values.rbac_enabled }}
serviceAccountName: {{ default ( printf "%s-le" ( include "cmdb.fullname" . ) ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- end }}
{{- end }}
{{- define "cmdb.install-sa" -}}
{{- if .Values.rbac_enabled }}
serviceAccountName: {{ default ( printf "%s-install" ( include "cmdb.fullname" . ) ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- end }}
{{- end }}
{{- define "cmdb.delete-sa" -}}
{{- if .Values.rbac_enabled }}
serviceAccountName: {{ default ( printf "%s-delete" ( include "cmdb.fullname" . ) ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- end }}
{{- end }}
{{/* Istio-suffixed SA if not passed in */}}
{{- define "cmdb.istio-sa" -}}
{{- if .Values.rbac_enabled }}
{{- if .Values.istio.enabled }}
serviceAccountName: {{ default ( printf "%s-istio" ( include "cmdb.fullname" . ) ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- else }}
serviceAccountName: {{ default ( printf "%s" ( include "cmdb.fullname" . ) ) ( default .Values.global.serviceAccountName .Values.serviceAccountName ) }}
{{- end }}
{{- end }}
{{- end }}
{{/* SA only if istio.enabled; otherwise none (STS) */}}
{{- define "cmdb.istio-only-sa" -}}
{{- if .Values.istio.enabled }}
{{- include "cmdb.istio-sa" . }}
{{- end }}
{{- end }}
{{/* Require SA only if simplex or istio.enabled; otherwise none (some Jobs) */}}
{{- define "cmdb.simplex-job-sa" -}}
{{- if eq (.Values.cluster_type) "simplex" }}
{{- include "cmdb.sa" . }}
{{- else }}
{{- include "cmdb.istio-only-sa" . }}
{{- end }}
{{- end }}

{{/*
Standard CMDB kubernetes (k8s) environment
*/}}
{{- define "cmdb-k8s.env" -}}
- name: K8S_NAMESPACE
  value: "{{ .Release.Namespace }}"
- name: K8S_LABELS
  value: app={{ template "cmdb.fullname" . }}
- name: K8S_PREFIX
  value: {{ template "cmdb.fullname" . }}
- name: K8S_POD_PREFIX
  value: {{ template "cmdb.pod-prefix" . }}
- name: K8S_CONTAINER_PREFIX
  value: {{ template "cmdb.container-prefix" . }}
- name: K8S_DOMAIN
  value: {{ .Values.clusterDomain }}
- name: ISTIO_ENABLED
  value: "{{ .Values.istio.enabled }}"
{{- end -}}
