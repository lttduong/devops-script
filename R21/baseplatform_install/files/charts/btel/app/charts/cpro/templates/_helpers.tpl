{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "prometheus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.fullname" -}}
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
Create a fully qualified alertmanager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}

{{- define "prometheus.alertmanager.fullname" -}}
{{- if .Values.alertmanager.fullnameOverride -}}
{{- .Values.alertmanager.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.alertmanager.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified kube-state-metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.kubeStateMetrics.fullname" -}}
{{- if .Values.kubeStateMetrics.fullnameOverride -}}
{{- .Values.kubeStateMetrics.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.kubeStateMetrics.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified node-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.nodeExporter.fullname" -}}
{{- if .Values.nodeExporter.fullnameOverride -}}
{{- .Values.nodeExporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.nodeExporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified name for migrate.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.migrate.fullname" -}}
{{- if .Values.server.migrate.fullnameOverride -}}
{{- .Values.server.migrate.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.migrate.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.migrate.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified zombie-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.zombieExporter.fullname" -}}
{{- if .Values.zombieExporter.fullnameOverride -}}
{{- .Values.zombieExporter.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.zombieExporter.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.zombieExporter.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.server.fullname" -}}
{{- if .Values.server.fullnameOverride -}}
{{- .Values.server.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.server.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified pushgateway name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.pushgateway.fullname" -}}
{{- if .Values.pushgateway.fullnameOverride -}}
{{- .Values.pushgateway.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.pushgateway.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.pushgateway.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified webhook4fluentd name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.webhook4fluentd.fullname" -}}
{{- if .Values.webhook4fluentd.fullnameOverride -}}
{{- .Values.webhook4fluentd.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.webhook4fluentd.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.webhook4fluentd.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified restserver name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.restserver.fullname" -}}
{{- if .Values.restserver.fullnameOverride -}}
{{- .Values.restserver.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name .Values.restserver.name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name .Values.restserver.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for networkpolicy.
*/}}
{{- define "prometheus.networkPolicy.apiVersion" -}}
{{- if semverCompare ">=1.4-0, <1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else if semverCompare "^1.7-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for extensions/v1beta1.
*/}}
{{- define "prometheus.apiVersionExtensionsV1Beta1orV1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified name for serviceAccount for alertmanager, kubeStateMetrics, pushgateway, server,
webhook4fluentd, restserver and migrate components
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.serviceAccount.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s" .Release.Name -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified name for serviceAccount for nodeExporter and zombieExporter components
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.exporters.serviceAccount.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s-%s" .Release.Name "exporters" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s-%s" .Release.Name $name "exporters" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for alertmanager, kubeStateMetrics, pushgateway, server,
webhook4fluentd, restserver and migrate components
*/}}
{{- define "prometheus.serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
    {{- print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- print (include "prometheus.serviceAccount.fullname" .) -}}
{{- else -}}
    {{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the nodeExporter and zombieExporter components
*/}}
{{- define "prometheus.exporters.serviceAccountName" -}}
{{- if .Values.exportersServiceAccountName -}}
    {{ default "default" .Values.exportersServiceAccountName }}
{{- else if .Values.rbac.enabled -}}
    {{ default (include "prometheus.exporters.serviceAccount.fullname" .) }}
{{- end -}}
{{- end -}}

{{/*
Return the prometheus components labels
*/}}
{{- define "custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the prometheus components annotations
*/}}
{{- define "custom-annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the prometheus components resource labels
*/}}
{{- define "prometheus-labels" -}}
{{- $prometheus_labels := index . 0 -}}
{{- range $key, $value :=  $prometheus_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the prometheus components resource annotations
*/}}
{{- define "prometheus-annotations" -}}
{{- $prometheus_annotations := index . 0 -}}
{{- range $key, $value :=  $prometheus_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for podsecuritypolicy.
*/}}
{{- define "prometheus.apiVersionExtensionsV1Beta1orPolicyV1Beta1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Create the name for the uri route-prefix
*/}}
{{- define "pushgateway.routePrefixURL" -}}
{{- if ne .Values.pushgateway.prefixURL "" }}
{{- printf "/%s" .Values.pushgateway.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.pushgateway.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create the name for the uri route-prefix
*/}}
{{- define "alertmanager.routePrefixURL" -}}
{{- if ne .Values.alertmanager.prefixURL "" }}
{{- printf "/%s" .Values.alertmanager.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.alertmanager.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
cert manager secret name
*/}}
{{- define "certManager.secretName" -}}
{{- printf "etcdcerts-%s-%s" .Release.Name (include "prometheus.name" .) -}}
{{- end -}}

{{/*
cert manager resource name
*/}}
{{- define "certManager.resourceName" -}}
{{- printf "etcdcerts-%s-%s" .Release.Name (include "prometheus.name" .) -}}
{{- end -}}

{{/*
Create the name for the uri route-prefix
*/}}
{{- define "server.routePrefixURL" -}}
{{- if ne .Values.server.prefixURL "" }}
{{- printf "/%s" .Values.server.prefixURL -}}
{{- else -}}
{{- $path := regexFind "[^/]+$" .Values.server.baseURL -}}
{{- if ne $path "" }}
{{- printf "/%s" $path -}}
{{- else -}}
{{- printf ""}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Return the deployment name 
*/}}
{{- define "prometheus.restserver.deploymentName" -}}
{{- if or (.Values.nameOverride) (.Values.restserver.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.restserver.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.restServerPod.name | default (include "prometheus.restserver.fullname" .) -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the helm test deployment name 
*/}}
{{- define "prometheus.restserver.helmTestDeploymentName" -}}
{{- $name := printf "%s-%s-%s" .Release.Name .Chart.Name  "restapi-test" -}}
{{- if ne .Values.customResourceNames.restServerHelmTestPod.name ""}}
{{- $name = .Values.customResourceNames.restServerHelmTestPod.name -}}
{{- end -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the restserver helm test container name
*/}}
{{- define "prometheus.restserver.helmTestRestServerContainerName" -}}
{{- $name := printf "%s-%s" .Release.Name "restapi-test" -}}
{{- if ne .Values.customResourceNames.restServerHelmTestPod.testContainer "" }}
{{- $name = .Values.customResourceNames.restServerHelmTestPod.testContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the restserver container name
*/}}
{{- define "prometheus.restserver.restServerContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .) .Values.restserver.name  -}}
{{- if ne .Values.customResourceNames.restServerPod.restServerContainer "" }}
{{- $name = .Values.customResourceNames.restServerPod.restServerContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the configmap container name
*/}}
{{- define "prometheus.restserver.configmapReloadContainerName" -}}
{{- $name := printf "%s-%s-%s" (include "prometheus.name" .) .Values.restserver.name  .Values.configmapReload.name -}}
{{- if ne .Values.customResourceNames.restServerPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.restServerPod.configMapReloadContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the alertmanager deployment or statefulSet name
*/}}
{{- define "prometheus.alertmanager.DeploymentOrStsName" -}}
{{- if or (.Values.nameOverride) (.Values.alertmanager.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.alertmanager.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.alertManagerPod.name | default (include "prometheus.alertmanager.fullname" .)  -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the alertmanager container name
*/}}
{{- define "prometheus.alertmanager.alertmanagerContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .) .Values.alertmanager.name -}}
{{- if ne .Values.customResourceNames.alertManagerPod.alertManagerContainer "" }}
{{- $name = .Values.customResourceNames.alertManagerPod.alertManagerContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the alertmanager configmap preload container name
*/}}
{{- define "prometheus.alertmanager.alertmanagerReloadContainerName" -}}
{{- $name := printf "%s-%s-%s" (include "prometheus.name" .) .Values.alertmanager.name .Values.configmapReload.name -}}
{{- if ne .Values.customResourceNames.alertManagerPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.alertManagerPod.configMapReloadContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the server deployment or statefulSet name
*/}}
{{- define "prometheus.server.DeploymentOrStsName" -}}
{{- if or (.Values.nameOverride) (.Values.server.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.server.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name :=.Values.customResourceNames.serverPod.name | default (include "prometheus.server.fullname" .)  -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the initChownData container name
*/}}
{{- define "prometheus.server.initChownDataContainerName" -}}
{{- $name := printf "%s" .Values.initChownData.name  -}}
{{- if ne .Values.customResourceNames.serverPod.inCntInitChownData "" }}
{{- $name = .Values.customResourceNames.serverPod.inCntInitChownData -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the server configmap reload container name
*/}}
{{- define "prometheus.server.configmapReloadContainerName" -}}
{{- $name := printf "%s-%s-%s" (include "prometheus.name" .) .Values.server.name .Values.configmapReload.name  -}}
{{- if ne .Values.customResourceNames.serverPod.configMapReloadContainer "" }}
{{- $name = .Values.customResourceNames.serverPod.configMapReloadContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the prometheus server container name
*/}}
{{- define "prometheus.server.prometheusContainerName" -}}
{{- $name := printf "%s-%s"  (include "prometheus.name" .) .Values.server.name  -}}
{{- if ne .Values.customResourceNames.serverPod.serverContainer "" }}
{{- $name = .Values.customResourceNames.serverPod.serverContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pushgateway deployment name
*/}}
{{- define "prometheus.pushgateway.deploymentName" -}}
{{- if or (.Values.nameOverride) (.Values.pushgateway.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.pushgateway.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name :=.Values.customResourceNames.pushGatewayPod.name | default (include "prometheus.pushgateway.fullname" .)  -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the pushgateway container name
*/}}
{{- define "prometheus.pushgateway.ContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .) .Values.pushgateway.name  -}}
{{- if ne .Values.customResourceNames.pushGatewayPod.pushGatewayContainer "" }}
{{- $name = .Values.customResourceNames.pushGatewayPod.pushGatewayContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the kubeStateMetrics deployment name
*/}}
{{- define "prometheus.kubeStateMetrics.deploymentName" -}}
{{- if or (.Values.nameOverride) (.Values.kubeStateMetrics.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.kubeStateMetrics.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name :=.Values.customResourceNames.kubeStateMetricsPod.name | default (include "prometheus.kubeStateMetrics.fullname" .)  -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the kubeStateMetrics container name
*/}}
{{- define "prometheus.kubeStateMetrics.ContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .) .Values.kubeStateMetrics.name  -}}
{{- if ne .Values.customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer "" }}
{{- $name = .Values.customResourceNames.kubeStateMetricsPod.kubeStateMetricsContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the hooks job name 
*/}}
{{- define "prometheus.hooks.postDeleteDepName" -}}
{{- $name := printf "%s-%s" (include "prometheus.server.fullname" .) "delete-jobs" -}}
{{- if ne .Values.customResourceNames.hooks.postDeleteJobName ""}}
{{- $name = .Values.customResourceNames.hooks.postDeleteJobName -}}
{{- end -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the hooks container name
*/}}
{{- define "prometheus.hooks.containerName" -}}
{{- $name := printf "%s" "post-delete-job"  -}}
{{- if ne .Values.customResourceNames.hooks.postDeleteContainer "" }}
{{- $name = .Values.customResourceNames.hooks.postDeleteContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the webhook4fluentd deployment name 
*/}}
{{- define "prometheus.webhook4fluentd.deploymentName" -}}
{{- if or (.Values.nameOverride) (.Values.webhook4fluentd.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.webhook4fluentd.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.webhook4fluentd.name | default (include "prometheus.webhook4fluentd.fullname" .) -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}

{{/*
Return the  webhook4fluentd container name
*/}}
{{- define "prometheus.webhook4fluentd.ContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .)  .Values.webhook4fluentd.name   -}}
{{- if ne .Values.customResourceNames.webhook4fluentd.webhookContainer "" }}
{{- $name = .Values.customResourceNames.webhook4fluentd.webhookContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}



{{/*
Return the node exporter daemonset name 
*/}}
{{- define "prometheus.nodeExporter.daemonSetName" -}}
{{- if or (.Values.nameOverride) (.Values.nodeExporter.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.nodeExporter.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.nodeExporter.name | default (include "prometheus.nodeExporter.fullname" .) -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}


{{/*
Return the  node exporter container name
*/}}
{{- define "prometheus.nodeExporter.ContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .)  .Values.nodeExporter.name   -}}
{{- if ne .Values.customResourceNames.nodeExporter.nodeExporterContainer "" }}
{{- $name = .Values.customResourceNames.nodeExporter.nodeExporterContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the zombie exporter daemonset name 
*/}}
{{- define "prometheus.zombieExporter.daemonSetName" -}}
{{- if or (.Values.nameOverride) (.Values.zombieExporter.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "prometheus.zombieExporter.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.zombieExporter.name | default (include "prometheus.zombieExporter.fullname" .) -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}


{{/*
Return the  zombie exporter container name
*/}}
{{- define "prometheus.zombieExporter.ContainerName" -}}
{{- $name := printf "%s-%s" (include "prometheus.name" .)  .Values.zombieExporter.name   -}}
{{- if ne .Values.customResourceNames.zombieExporter.zombieExporterContainer "" }}
{{- $name = .Values.customResourceNames.zombieExporter.zombieExporterContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the pre-upgrade job name 
*/}}
{{- define "prometheus.migrate.preUpgradePodName" -}}
{{- $name := printf "%s-%s" (include "prometheus.migrate.fullname" .) "pre" -}}
{{- if ne .Values.customResourceNames.migrate.preUpgradePodName ""}}
{{- $name = .Values.customResourceNames.migrate.preUpgradePodName -}}
{{- end -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the  pre-upgrade container name
*/}}
{{- define "prometheus.migrate.preUpgradeContainer" -}}
{{- $name := printf "%s" "cpro-server"  -}}
{{- if ne .Values.customResourceNames.migrate.preUpgradeContainer "" }}
{{- $name = .Values.customResourceNames.migrate.preUpgradeContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the post-upgrade job name 
*/}}
{{- define "prometheus.migrate.postUpgradePodName" -}}
{{- $name := printf "%s-%s" (include "prometheus.migrate.fullname" .) "post" -}}
{{- if ne .Values.customResourceNames.migrate.postUpgradePodName ""}}
{{- $name = .Values.customResourceNames.migrate.postUpgradePodName -}}
{{- end -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the  post-upgrade container name
*/}}
{{- define "prometheus.migrate.postUpgradeContainer" -}}
{{- $name := printf "%s" "post-delete"  -}}
{{- if ne .Values.customResourceNames.migrate.postUpgradeContainer "" }}
{{- $name = .Values.customResourceNames.migrate.postUpgradeContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the server helm test deployment name 
*/}}
{{- define "prometheus.server.serverHelmTestPod" -}}
{{- $name := printf "%s-%s-%s" .Release.Name .Chart.Name  "status-test" -}}
{{- if ne .Values.customResourceNames.serverHelmTestPod.name ""}}
{{- $name = .Values.customResourceNames.serverHelmTestPod.name -}}
{{- end -}}
{{ template "prometheus.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the server helm test container name
*/}}
{{- define "prometheus.server.serverHelmTestContainer" -}}
{{- $name := printf "%s-%s" .Release.Name "status-test" -}}
{{- if ne .Values.customResourceNames.serverHelmTestPod.testContainer "" }}
{{- $name = .Values.customResourceNames.serverHelmTestPod.testContainer -}}
{{- end -}}
{{ template "prometheus.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{- define "prometheus.finalPodName" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.podNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}

{{- define "prometheus.finalContainerName" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.containerNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalConName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalConName -}}
{{- end -}}

{{/*
Create a fully qualified alertmanager name for helmtest.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.alertmanager.fullname.helmtest" -}}
{{- if .Values.ha.enabled -}}
{{ template  "prometheus.alertmanager.fullname" . }}-ext
{{- else -}}
{{ template  "prometheus.alertmanager.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create a fully qualified Prometheus server name for helmtest.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "prometheus.server.fullname.helmtest" -}}
{{- if .Values.ha.enabled -}}
{{ template  "prometheus.server.fullname" . }}-ext
{{- else -}}
{{ template  "prometheus.server.fullname" . }}
{{- end -}}
{{- end -}}

