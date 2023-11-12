{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "grafana.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "grafana.fullname" -}}
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
{{- define "grafana.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the name of the service account
*/}}
{{- define "grafana.serviceAccountName" -}}
{{- if .Values.serviceAccountName -}}
    {{- print .Values.serviceAccountName -}}
{{- else if .Values.global.serviceAccountName -}}
    {{- print .Values.global.serviceAccountName -}}
{{- else if .Values.rbac.enabled -}}
    {{- print (include "grafana.fullname" .) -}}
{{- else -}}
    {{- print "default" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified cmdb name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "grafana.cmdb.fullname" -}}
{{- $name := default "cmdb-mysql" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for apps/v1beta2.
*/}}
{{- define "prometheus.apiVersionAppsV1Beta2orV1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1beta2" -}}
{{- else -}}
{{- print "apps/v1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the path for the virtual service.
*/}}
{{- define "grafana.rooturl" -}}
{{- $path := regexFind "[^/]+$" .Values.grafana_ini.server.root_url -}}
{{- if eq $path "" }}
{{- printf "" -}}
{{- else -}}
{{- printf "%s" $path  -}}
{{- end -}}
{{- end -}}

{{/*
Return the userid for the containers.
*/}}
{{- define "grafana.user" -}}
{{- default .Values.runAsUser | default 65534 }}
{{- end -}}

{{/*
Return the fsGroup value for the containers.
*/}}
{{- define "grafana.fsgroup" -}}
{{- default .Values.fsGroup | default 65534 }}
{{- end -}}

{{/*
Return the probe url.
*/}}
{{- define "grafana.probe" -}}
{{- $path := regexFind "[^/]+$" .Values.grafana_ini.server.root_url -}}
{{- if eq $path "" }}
{{- printf "" -}}
{{- else -}}
{{- printf "/%s"  $path  -}}
{{- end -}}
{{- end -}}

{{/*
Return the grafana labels
*/}}
{{- define "custom-labels" -}}
{{- $customized_labels := index . 0 -}}
{{- range $key, $value :=  $customized_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the grafana annotations
*/}}
{{- define "custom-annotations" -}}
{{- $customized_annotations := index . 0 -}}
{{- range $key, $value :=  $customized_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the grafana component resource labels
*/}}
{{- define "grafana-labels" -}}
{{- $grafana_labels := index . 0 -}}
{{- range $key, $value :=  $grafana_labels }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the grafana component resource annotations
*/}}
{{- define "grafana-annotations" -}}
{{- $grafana_annotations := index . 0 -}}
{{- range $key, $value :=  $grafana_annotations }}
{{ $key }}: {{ $value }}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for podsecuritypolicy.
*/}}
{{- define "grafana.apiVersionExtensionsV1Beta1orPolicyV1Beta1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "extensions/v1beta1" -}}
{{- else -}}
{{- print "policy/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Return the appropriate apiVersion for serviceEntry
*/}}
{{- define "grafana.apiVersionNetworkIstioV1Alpha3orV1Beta1" -}}
{{- if eq .Values.global.istioVersion 1.4 -}}
{{- print "networking.istio.io/v1alpha3" -}}
{{- else -}}
{{- print "networking.istio.io/v1beta1" -}}
{{- end -}}
{{- end -}}


{{/*
Return the pod name of delete datasource job 
*/}}
{{- define "grafana.deleteDatasource" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "delete-datasource" -}}
{{- if ne .Values.customResourceNames.deleteDatasourceJobPod.name ""}}
{{- $name = .Values.customResourceNames.deleteDatasourceJobPod.name -}}
{{- end -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of delete datasource container  
*/}}
{{- define "grafana.deleteDatasourceContainer" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "delete-datasource" -}}
{{- if ne .Values.customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer ""}}
{{- $name = .Values.customResourceNames.deleteDatasourceJobPod.deleteDatasourceContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the pod name of set datasource job 
*/}}
{{- define "grafana.setDatasource" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "set-datasource" -}}
{{- if ne .Values.customResourceNames.setDatasourceJobPod.name ""}}
{{- $name = .Values.customResourceNames.setDatasourceJobPod.name -}}
{{- end -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of set datasource container  
*/}}
{{- define "grafana.setDatasourceContainer" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "set-datasource" -}}
{{- if ne .Values.customResourceNames.setDatasourceJobPod.setDatasourceContainer ""}}
{{- $name = .Values.customResourceNames.setDatasourceJobPod.setDatasourceContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the pod name of post upgrade job 
*/}}
{{- define "grafana.postUpgradejob" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "post-upgrade" -}}
{{- if ne .Values.customResourceNames.postUpgradeJobPod.name ""}}
{{- $name = .Values.customResourceNames.postUpgradeJobPod.name -}}
{{- end -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of post upgrade container
*/}}
{{- define "grafana.postUpgradejobContainer" -}}
{{- $name := printf "%s" "sqlitetomdb-post-upgrade" -}}
{{- if ne .Values.customResourceNames.postUpgradeJobPod.postUpgradeJobContainer ""}}
{{- $name = .Values.customResourceNames.postUpgradeJobPod.postUpgradeJobContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of post delete job 
*/}}
{{- define "grafana.postDeletejobPod" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "delete-jobs" -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.name ""}}
{{- $name = .Values.customResourceNames.postDeleteJobPod.name -}}
{{- end -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of post delete container 
*/}}
{{- define "grafana.deletedbContainer" -}}
{{- $name := printf "%s"  "grafana-deletedb" -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.deletedbContainer ""}}
{{- $name = .Values.customResourceNames.postDeleteJobPod.deletedbContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of post delete container 
*/}}
{{- define "grafana.deletesecretsContainer" -}}
{{- $name := printf "%s"  "post-delete-secrets" -}}
{{- if ne .Values.customResourceNames.postDeleteJobPod.deletesecretsContainer ""}}
{{- $name = .Values.customResourceNames.postDeleteJobPod.deletesecretsContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}

{{/*
Return the pod name of import dashboard job 
*/}}
{{- define "grafana.importDashboardjobPod" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "import-dashboard" -}}
{{- if ne .Values.customResourceNames.importDashboardJobPod.name ""}}
{{- $name = .Values.customResourceNames.importDashboardJobPod.name -}}
{{- end -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the pod name of import dashboard container
*/}}
{{- define "grafana.importDashboardjobContainer" -}}
{{- $name := printf "%s-%s" (include "grafana.fullname" .) "import-dashboard" -}}
{{- if ne .Values.customResourceNames.importDashboardJobPod.importDashboardJobContainer ""}}
{{- $name = .Values.customResourceNames.importDashboardJobPod.importDashboardJobContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the statefulset name 
*/}}
{{- define "grafana.stsName" -}}
{{- if or (.Values.nameOverride) (.Values.fullnameOverride) }}
{{- $truncLen := .Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- printf "%s" (include "grafana.fullname" .) | trunc ( $truncLen |int) | trimSuffix "-" -}}
{{- else -}}
{{- $name := .Values.customResourceNames.grafanaPod.name | default (include "grafana.fullname" .) -}}
{{ template "grafana.finalPodName" ( dict "name" $name  "context" . )  }}
{{- end -}}
{{- end -}}


{{/*
Return the grafana init-container changedbschema 
*/}}
{{- define "grafana.changeDbschema" -}}
{{- $name := printf "%s" "change-db-schema"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntChangeDbSchema "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntChangeDbSchema -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana init-container changeMariadbSchema
*/}}
{{- define "grafana.changeMariadbSchema" -}}
{{- $name := printf "%s" "change-mariadb-schema"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntChangeMariadbSchema "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntChangeMariadbSchema -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana init-container wait-for-mariadb
*/}}
{{- define "grafana.waitforMariadb" -}}
{{- $name := printf "%s" "wait-for-mariadb"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntWaitforMariadb "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntWaitforMariadb -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana init-container download-dashboard
*/}}
{{- define "grafana.downloadDashboards" -}}
{{- $name := printf "%s" "download-dashboards"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.inCntDownloadDashboard "" }}
{{- $name = .Values.customResourceNames.grafanaPod.inCntDownloadDashboard -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container plugin-sidecar
*/}}
{{- define "grafana.pluginsidecarContainerName" -}}
{{- $name := printf "%s" "plugins-sidecar"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.pluginSidecarContainer "" }}
{{- $name = .Values.customResourceNames.grafanaPod.pluginSidecarContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container grafana-dashboard
*/}}
{{- define "grafana.grafanaSidecarDashboard" -}}
{{- $name := printf "%s-%s" (include "grafana.name" .) "sc-dashboard"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaSidecarDashboard "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaSidecarDashboard -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container grafana-sane-authproxy
*/}}
{{- define "grafana.grafanaSaneAuthProxy" -}}
{{- $name := printf "%s-%s" (include "grafana.name" .) "sane-authproxy"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaSaneAuthproxy "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaSaneAuthproxy -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container grafana-mdb-tool
*/}}
{{- define "grafana.grafanaMdbtool" -}}
{{- $name := printf "%s" "grafana-mdb-tool"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaMdbtool "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaMdbtool -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container grafana-sc-datasources
*/}}
{{- define "grafana.grafanaDatasource" -}}
{{- $name := printf "%s-%s" (include "grafana.name" .) "sc-datasources"  -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaDatasource "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaDatasource -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}


{{/*
Return the grafana container grafanaContainer
*/}}
{{- define "grafana.grafanaContainer" -}}
{{- $name := printf "%s" .Chart.Name  -}}
{{- if ne .Values.customResourceNames.grafanaPod.grafanaContainer "" }}
{{- $name = .Values.customResourceNames.grafanaPod.grafanaContainer -}}
{{- end -}}
{{ template "grafana.finalContainerName" ( dict "name" $name  "context" . )  }}
{{- end -}}



{{- define "grafana.finalPodName" -}}
{{- $name := .name -}}
{{- $context := .context -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.podNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalName -}}
{{- end -}}


{{- define "grafana.finalContainerName" -}}
{{- $context := .context -}}
{{- $name := .name -}}
{{- $truncLen := $context.Values.customResourceNames.resourceNameLimit | default 63 -}}
{{- $prefix :=  $context.Values.global.containerNamePrefix | default "" -}}
{{- $result := dict -}}
{{-   $_ := set $result "finalConName" (printf "%s%s" $prefix $name | trunc ( $truncLen |int) | trimSuffix "-") -}}
{{- $result.finalConName -}}
{{- end -}}
