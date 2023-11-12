{{/* vim: set filetype=mustache: */}}
{{/*
Common set of labels for all resources
*/}}
{{- define "cmdb-mariadb.labels" }}
app: {{ template "cmdb.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: cmdb
csf-subcomponent: mariadb
cmdb-dbtype: mariadb
{{- end -}}

{{- define "cmdb-maxscale.labels" }}
app: {{ template "cmdb.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: cmdb
csf-subcomponent: maxscale
cmdb-dbtype: mariadb
{{- end -}}

{{- define "cmdb-admin.labels" }}
app: {{ template "cmdb.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: cmdb
csf-subcomponent: admin
cmdb-dbtype: mariadb
{{- end -}}

{{- define "cmdb-test.labels" }}
app: {{ template "cmdb.fullname" . }}
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
csf-component: cmdb
csf-subcomponent: test
cmdb-dbtype: mariadb
{{- end -}}