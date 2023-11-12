{{/* vim: set filetype=mustache: */}}
{{/*
A set of templates, which provide a particular built-in user password
based on if one was passed in as a value or not (and thus generated).

Provide a simple "interface" so that every location doesn't have to 
detect generated vs not.

Each template has an .enc and .dec variant which provides the b64 encoded
or decoded password.
*/}}

{{- define "cmdb.pw.root.enc" -}}
{{ .Values.mariadb.root_password | default (include "cmdb.pwgen.root" .) }}
{{- end -}}
{{- define "cmdb.pw.root.dec" -}}
{{ include "cmdb.pw.root.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.repl.enc" -}}
{{ .Values.mariadb.repl_user_password | default (include "cmdb.pwgen.repl" .) }}
{{- end -}}
{{- define "cmdb.pw.repl.dec" -}}
{{ include "cmdb.pw.repl.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.metrics.enc" -}}
{{ .Values.mariadb.metrics.metrics_password | default (include "cmdb.pwgen.metrics" .) }}
{{- end -}}
{{- define "cmdb.pw.metrics.dec" -}}
{{ include "cmdb.pw.metrics.enc" . | b64dec }}
{{- end -}}

{{- define "cmdb.pw.maxscale.enc" -}}
{{ .Values.maxscale.maxscale_user_password | default (include "cmdb.pwgen.maxscale" .) }}
{{- end -}}
{{- define "cmdb.pw.maxscale.dec" -}}
{{ include "cmdb.pw.maxscale.enc" . | b64dec }}
{{- end -}}
