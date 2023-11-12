{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "rabbitmq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "rabbitmq.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rabbitmq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create managemenbt service name used by certmanager
*/}}
{{- define "rabbitmq.management.service" -}}
{{- if .Values.managementnameOverride -}}
{{- .Values.managementnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "mgt" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create prometheus service name used by certmanager
*/}}
{{- define "rabbitmq.prometheus.service" -}}
{{- if .Values.prometheusnameOverride -}}
{{- .Values.prometheusnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pro" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create rbac ApiVersion
*/}}
{{- define "rbac.apiVersion" -}}
{{- if semverCompare ">=1.8" .Capabilities.KubeVersion.GitVersion -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "PSPVersion" -}}
{{- if semverCompare "<1.16.0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "certificateVersion" -}}
{{- if semverCompare "<1.16.0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "certmanager.k8s.io/v1alpha1" -}}
{{- else -}}
{{- print "cert-manager.io/v1alpha2" -}}
{{- end -}}
{{- end -}}

{{/*
Create suffix on pod/container
*/}}

{{- define "postDeleteJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postDeleteJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postDeleteJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postDeleteJobName -}}
{{- .Values.postDeleteJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "pod-delete-jobs" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postDeleteContainerName" -}}
{{- if and .Values.global.podNamePrefix .Values.postDeleteContainerName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postDeleteContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postDeleteContainerName -}}
{{- .Values.postDeleteContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-delete-job"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postInstallJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postInstallJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postInstallJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postInstallJobName -}}
{{- .Values.postInstallJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "dynamic-config-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postInstallContainerName" -}}
{{- if and .Values.global.podNamePrefix .Values.postInstallContainerName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postInstallContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postInstallContainerName -}}
{{- .Values.postInstallContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "dynamic-config-pod"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postUpgradeJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postUpgradeJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postUpgradeJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postUpgradeJobName -}}
{{- .Values.postUpgradeJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-upgrade-job" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postUpgradeContainerName" -}}
{{- if and .Values.global.podNamePrefix .Values.postUpgradeContainerName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postUpgradeContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postUpgradeContainerName -}}
{{- .Values.postUpgradeContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "post-upgrade-pod"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postScaleinJobName" -}}
{{- if and .Values.global.podNamePrefix .Values.postScaleinJobName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postScaleinJobName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postScaleinJobName -}}
{{- .Values.postScaleinJobName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "postscalein" | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "postScaleinContainerName" -}}
{{- if and .Values.global.podNamePrefix .Values.postScaleinContainerName -}}
{{- printf "%s%s" .Values.global.podNamePrefix .Values.postScaleinContainerName | trunc 50 | trimSuffix "-" -}}
{{- else if .Values.postScaleinContainerName -}}
{{- .Values.postScaleinContainerName | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s-%s" .Release.Name $name "postscalein"| trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "csf-toolkit-helm.annotations" -}}
{{- $envAll := index . 0 -}}
{{- $global_annotations := $envAll.Values.global.annotations }}
{{- $customized_annotations := index . 1 }}
{{- $final_annotations := merge $customized_annotations $global_annotations}}
{{- range $key, $value := $final_annotations }}
{{$key}}: {{$value | quote }}
{{- end -}}
{{- end -}}

{{ define "crmq.commonLabels" }}
app.kubernetes.io/name: "{{ template "rabbitmq.fullname" . }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "helm"
app.kubernetes.io/component: "messageBroker"
app.kubernetes.io/part-of: "{{.Values.partOf}}"
app.kubernetes.io/version: "{{.Chart.Version}}"
{{- end -}}

{{- define "rabbitmq.mtlsmode" -}}
{{- if .Values.istio.permissive -}}
{{- printf "%s" "PERMISSIVE" -}}
{{- else -}}
{{- printf "%s" "STRICT" -}}
{{- end -}}
{{- end -}}
