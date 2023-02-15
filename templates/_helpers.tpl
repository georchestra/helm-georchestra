{{/*
Expand the name of the chart.
*/}}
{{- define "georchestra.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "georchestra.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "georchestra.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "georchestra.labels" -}}
helm.sh/chart: {{ include "georchestra.chart" . }}
{{ include "georchestra.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "georchestra.selectorLabels" -}}
app.kubernetes.io/name: {{ include "georchestra.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "georchestra.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "georchestra.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Insert database georchestra environment variables
*/}}
{{- define "georchestra.database-georchestra-envs" -}}
{{- $database := .Values.database -}}
{{- if $database.builtin }}
- name: PGHOST
  value: "{{ .Release.Name }}-database"
{{- else }}
- name: PGHOST
  valueFrom:
    secretKeyRef:
        name: {{ include "georchestra.fullname" . }}-database-georchestra-secret
        key: host
        optional: false
{{- end }}
- name: PGPORT
  valueFrom:
    secretKeyRef:
        name: {{ include "georchestra.fullname" . }}-database-georchestra-secret
        key: port
        optional: false
- name: PGDATABASE
  valueFrom:
    secretKeyRef:
        name: {{ include "georchestra.fullname" . }}-database-georchestra-secret
        key: dbname
        optional: false
- name: PGUSER
  valueFrom:
    secretKeyRef:
        name: {{ include "georchestra.fullname" . }}-database-georchestra-secret
        key: user
        optional: false
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ include "georchestra.fullname" . }}-database-georchestra-secret
        key: password
        optional: false
{{- end }}

{{/*
Insert LDAP environment variables
*/}}
{{- define "georchestra.ldap-envs" -}}
{{- $ldap := .Values.ldap -}}
{{- if .Values.georchestra.webapps.openldap.enabled }}
- name: LDAPHOST
  value: "{{ include "georchestra.fullname" . }}-ldap-svc"
{{- else }}
- name: LDAPHOST
  value: "{{ $ldap.host }}"
{{- end }}
- name: LDAPPORT
  value: "{{ $ldap.port }}"
- name: LDAPSCHEME
  value: "{{ $ldap.scheme }}"
- name: LDAPBASEDN
  value: "{{ $ldap.baseDn }}"
- name: LDAPADMINDN
  value: "{{ $ldap.adminDn }}"
- name: LDAPADMINPASSWORD
  value: "{{ $ldap.adminPassword }}"
- name: LDAPUSERSRDN
  value: "{{ $ldap.usersRdn }}"
- name: LDAPROLESRDN
  value: "{{ $ldap.rolesRdn }}"
- name: LDAPORGSRDN
  value: "{{ $ldap.orgsRdn }}"
{{- end }}

{{/*
Insert common environment variables
*/}}
{{- define "georchestra.common-envs" -}}
- name: FQDN
  value: "{{ .Values.fqdn }}"
{{- if .Values.georchestra.smtp_smarthost.enabled }}
- name: SMTPHOST
  value: "{{ include "georchestra.fullname" . }}-smtp-svc"
- name: SMTPPORT
  value: "25"
{{- end }}
{{- end }}