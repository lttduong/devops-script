{{/* vim: set filetype=mustache: */}}
{{/*
Image path definitions using global registry or overridden image for testing.
*/}}
{{/*
  MariaDB Images
*/}}
{{- define "cmdb-mariadb.image" -}}
{{- if .Values.mariadb.image.registry }}
image: "{{ .Values.mariadb.image.registry }}/{{ .Values.mariadb.image.name }}:{{ .Values.mariadb.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry }}/{{ .Values.mariadb.image.name }}:{{ .Values.mariadb.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.mariadb.image.pullPolicy | quote }}
{{- end -}}

{{- define "cbur-mariadb.image" -}}
{{- if .Values.cbur.image.registry }}
image: "{{ .Values.cbur.image.registry }}/{{ .Values.cbur.image.name }}:{{ .Values.cbur.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry2 }}/{{ .Values.cbur.image.name }}:{{ .Values.cbur.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.cbur.image.pullPolicy }}
{{- end -}}

{{- define "mariadb-metrics.image" -}}
{{- if .Values.mariadb.metrics.image.registry }}
image: "{{ .Values.mariadb.metrics.image.registry }}/{{ .Values.mariadb.metrics.image.name }}:{{ .Values.mariadb.metrics.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry1 }}/{{ .Values.mariadb.metrics.image.name }}:{{ .Values.mariadb.metrics.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.mariadb.metrics.image.pullPolicy | quote }}
{{- end -}}

{{/*
  MaxScale Images
*/}}
{{- define "cmdb-maxscale.image" -}}
{{- if .Values.maxscale.image.registry }}
image: "{{ .Values.maxscale.image.registry }}/{{ .Values.maxscale.image.name }}:{{ .Values.maxscale.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry }}/{{ .Values.maxscale.image.name }}:{{ .Values.maxscale.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.maxscale.image.pullPolicy | quote }}
{{- end -}}

{{- define "maxscale-elector.image" -}}
{{- if .Values.maxscale.elector.image.registry }}
image: "{{ .Values.maxscale.elector.image.registry }}/{{ .Values.maxscale.elector.image.name }}:{{ .Values.maxscale.elector.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry2 }}/{{ .Values.maxscale.elector.image.name }}:{{ .Values.maxscale.elector.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.maxscale.elector.image.pullPolicy | quote }}
{{- end -}}

{{- define "maxscale-metrics.image" -}}
{{- if .Values.maxscale.metrics.image.registry }}
image: "{{ .Values.maxscale.metrics.image.registry }}/{{ .Values.maxscale.metrics.image.name }}:{{ .Values.maxscale.metrics.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry }}/{{ .Values.maxscale.metrics.image.name }}:{{ .Values.maxscale.metrics.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.maxscale.metrics.image.pullPolicy | quote }}
{{- end -}}

{{/*
  Admin Images
*/}}
{{- define "cmdb-admin.image" -}}
{{- if .Values.admin.image.registry }}
image: "{{ .Values.admin.image.registry }}/{{ .Values.admin.image.name }}:{{ .Values.admin.image.tag }}"
{{- else }}
image: "{{ .Values.global.registry }}/{{ .Values.admin.image.name }}:{{ .Values.admin.image.tag }}"
{{- end }}
imagePullPolicy: {{ .Values.admin.image.pullPolicy | quote }}
{{- end -}}
