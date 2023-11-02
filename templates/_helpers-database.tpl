{{/*
Insert database georchestra environment variables
*/}}
{{- define "georchestra.database-georchestra-envs" -}}
{{- $database := .Values.database -}}
{{- $database_secret_georchestra_name := printf "%s-database-georchestra-secret" (include "georchestra.fullname" .) -}}
{{- if $database.builtin }}
- name: PGHOST
  value: "{{ .Release.Name }}-database"
{{- else }}
{{- if $database.auth.existingSecret }}
{{- $database_secret_georchestra_name = $database.auth.existingSecret -}}
{{- end }}
- name: PGHOST
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_georchestra_name }}
        key: host
        optional: false
{{- end }}
- name: PGPORT
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_georchestra_name }}
        key: port
        optional: false
- name: PGDATABASE
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_georchestra_name }}
        key: dbname
        optional: false
- name: PGUSER
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_georchestra_name }}
        key: user
        optional: false
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $database_secret_georchestra_name }}
        key: password
        optional: false
{{- end }}
