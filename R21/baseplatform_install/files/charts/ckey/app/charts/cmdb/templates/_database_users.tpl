{{/* vim: set filetype=mustache: */}}
{{/*
A representation of the database_users.json contents built as YAML-string and
converted to JSON
*/}}

{{- define "cmdb.database_users.json" -}}
{{ include "cmdb.database_users.yaml" . | fromYaml | toJson }}
{{- end }}

{{- define "cmdb.database_users.yaml" -}}
MariaDB:
  Built-in Users:
  - User: root
    Password: {{ include "cmdb.pw.root.enc" . | quote }}
  {{- if ne (.Values.cluster_type) "simplex" }}
  - User: {{ .Values.mariadb.repl_user }}
    Password: {{ include "cmdb.pw.repl.enc" . | quote }}
  {{- end }}
  {{- if .Values.mariadb.metrics.enabled }}
  - User: {{ .Values.mariadb.metrics.user }}
    Password: {{ include "cmdb.pw.metrics.enc" . | quote }}
  {{- end }}
  {{- if gt (int .Values.maxscale.count) 0 }}
  - User: {{ .Values.maxscale.maxscale_user }}
    Password: {{ include "cmdb.pw.maxscale.enc" . | quote }}
  {{- end }}
  Add Users:
  {{- $set_requires := .Values.mariadb.use_tls }}
  {{- if .Values.mariadb.users }}
  {{- range $index, $item := .Values.mariadb.users }}
  - User: {{ $item.name | quote }}
    Host: {{ $item.host | quote }}
    Password: {{ $item.password | quote }}
    Grant Privilege: {{ $item.privilege | quote }}
    Grant Object: {{ $item.object | quote }}
    {{- if $set_requires }}
    Grant Requires: {{ $item.requires | quote }}
    {{- end }}
    Grant With: {{ $item.with | quote }}
  {{- end }}
  {{- end }}

  {{/* Special handling for allow_root_all */}}
  {{- if .Values.mariadb.allow_root_all }}
  - User: "root"
    Host: "%"
    Password: {{ include "cmdb.pw.root.enc" . | quote }}
    Grant Privilege: "ALL PRIVILEGES"
    Grant Object: "*.*"
    {{- if $set_requires }}
    Grant Requires: "SSL"
    {{- end }}
    Grant With: "GRANT OPTION"
  {{- end }}

  {{/* Add metrics user */}}
  {{- if .Values.mariadb.metrics.enabled }}
  - User: {{ .Values.mariadb.metrics.user | quote }}
    Host: "localhost"
    Password: {{ include "cmdb.pw.metrics.enc" . | quote }}
    Grant Privilege: "PROCESS, REPLICATION CLIENT, SELECT"
    Grant Object: "*.*"
    Grant With: "MAX_USER_CONNECTIONS 3"
  - User: {{ .Values.mariadb.metrics.user | quote }}
    Host: "127.0.0.1"
    Password: {{ include "cmdb.pw.metrics.enc" . | quote }}
    Grant Privilege: "PROCESS, REPLICATION CLIENT, SELECT"
    Grant Object: "*.*"
    Grant With: "MAX_USER_CONNECTIONS 3"
  - User: {{ .Values.mariadb.metrics.user | quote }}
    Host: "::1"
    Password: {{ include "cmdb.pw.metrics.enc" . | quote }}
    Grant Privilege: "PROCESS, REPLICATION CLIENT, SELECT"
    Grant Object: "*.*"
    Grant With: "MAX_USER_CONNECTIONS 3"
  {{- end }}

{{- end }}

