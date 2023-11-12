{{/* vim: set filetype=mustache: */}}
{{/*
Return the appropriate apiVersion for role/rolebinding.
*/}}
{{- define "apiVersionRbacAuthorizatioK8sIoV1Beta1orV1" -}}
{{- if semverCompare "<1.16.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- end -}}
{{- end -}}