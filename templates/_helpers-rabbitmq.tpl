{{/*
Insert rabbitmq georchestra environment variables
*/}}
{{- define "georchestra.rabbitmq-georchestra-envs" -}}
{{- $rabbitmq := .Values.rabbitmq -}}
{{- $rabbitmq_secret_georchestra_name := "" -}}
{{- if $rabbitmq.builtin }}
{{- $rabbitmq_secret_georchestra_name = printf "%s-rabbitmq-georchestra-secret" (include "georchestra.fullname" .) -}}
- name: RABBITMQ_HOST
  value: "{{ .Release.Name }}-rabbitmq"
{{- else }}
{{- $rabbitmq_secret_georchestra_name = .Values.rabbitmq.auth.existingSecret -}}
- name: RABBITMQ_HOST
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: host
        optional: false
{{- end }}
- name: RABBITMQ_PORT
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: port
        optional: false
- name: RABBITMQ_USERNAME
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: user
        optional: false
- name: RABBITMQ_PASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $rabbitmq_secret_georchestra_name }}
        key: password
        optional: false
{{- end }}
