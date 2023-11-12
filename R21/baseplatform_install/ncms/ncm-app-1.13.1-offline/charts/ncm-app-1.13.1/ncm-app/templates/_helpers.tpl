{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "ncm-app.fullname" -}}
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

{{- define "ncmHost" -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s.%s.svc.cluster.local" .Values.fullnameOverride .Release.Namespace| trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- printf "%s.%s.svc.cluster.local" .Release.Name .Release.Namespace| trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s.%s.svc.cluster.local" .Release.Name $name .Release.Namespace| trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common labels used in chart resources
*/}}
{{- define "ncm-app.labels" -}}
app.kubernetes.io/name: {{ include "ncm-app.fullname" . }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
app.kubernetes.io/instance: "{{ .Release.Name }}"
app.kubernetes.io/managed-by: "{{ .Release.Service }}"
app.kubernetes.io/component: "{{ .Values.service.name }}"
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/part-of: "NCS"
{{- end -}}

{{/*
Common nodeSeclector toleration and affinity used in chart resources
*/}}
{{- define "placement.spec" -}}
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.affinity }}
affinity:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Check certificate api version from cert manager
*/}}
{{- define "ncm-app.certAPIexist" -}}
{{- if or (.Capabilities.APIVersions.Has "cert-manager.io/v1") (or (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") ( or (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3") (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2"))) }}
{{- print "true" }}
{{- else }}
{{- print "false" }}
{{- end }}
{{- end -}}


{{- define "ncm-app.certAPIversion" -}}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1") }}
apiVersion: cert-manager.io/v1
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") }}
apiVersion: cert-manager.io/v1beta1
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3") }}
apiVersion: cert-manager.io/v1alpha3
{{- else if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") }}
apiVersion: cert-manager.io/v1alpha2
{{- end }}
{{- end -}}

{{- define "ncm-app.certDelete" -}}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1") }}
kubectl delete certificates.v1.cert-manager.io/{{ template "ncm-app.fullname" . }}-cert --namespace {{.Release.Namespace}} --ignore-not-found --wait=true
{{- end }}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha2") }}
kubectl delete certificates.v1alpha2.cert-manager.io/{{ template "ncm-app.fullname" . }}-cert --namespace {{.Release.Namespace}} --ignore-not-found --wait=true
{{- end }}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1alpha3") }}
kubectl delete certificates.v1alpha3.cert-manager.io/{{ template "ncm-app.fullname" . }}-cert --namespace {{.Release.Namespace}} --ignore-not-found --wait=true
{{- end }}
{{- if (.Capabilities.APIVersions.Has "cert-manager.io/v1beta1") }}
kubectl delete certificates.v1beta1.cert-manager.io/{{ template "ncm-app.fullname" . }}-cert --namespace {{.Release.Namespace}} --ignore-not-found --wait=true
{{- end }}
{{- end -}}
