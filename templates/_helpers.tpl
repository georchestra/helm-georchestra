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
  valueFrom:
    secretKeyRef:
      name: {{ $ldap.existingSecret | default (printf "%s-ldap-passwords-secret" (include "georchestra.fullname" .)) }}
      key: SLAPD_PASSWORD
      optional: false
- name: LDAPUSERSRDN
  value: "{{ $ldap.usersRdn }}"
- name: LDAPROLESRDN
  value: "{{ $ldap.rolesRdn }}"
- name: LDAPORGSRDN
  value: "{{ $ldap.orgsRdn }}"
{{- end }}

{{/*
Insert service host environment variables
*/}}
{{- define "georchestra.service-envs" -}}
- name: ANALYTICS_HOST
  value: "{{ include "georchestra.fullname" . }}-analytics-svc"
- name: CAS_HOST
  value: "{{ include "georchestra.fullname" . }}-cas-svc"
- name: CONSOLE_HOST
  value: "{{ include "georchestra.fullname" . }}-console-svc"
- name: GEONETWORK_HOST
  value: "{{ include "georchestra.fullname" . }}-geonetwork-svc"
- name: GEOSERVER_HOST
  value: "{{ include "georchestra.fullname" . }}-geoserver-svc"
- name: HEADER_HOST
  value: "{{ include "georchestra.fullname" . }}-header-svc"
- name: GEOWEBCACHE_HOST
  value: "{{ include "georchestra.fullname" . }}-geowebcache-svc"
- name: MAPSTORE_HOST
  value: "{{ include "georchestra.fullname" . }}-mapstore-svc"
- name: DATAFEEDER_HOST
  value: "{{ include "georchestra.fullname" . }}-datafeeder-svc"
- name: IMPORT_HOST
  value: "{{ include "georchestra.fullname" . }}-import-svc"
- name: DATAHUB_HOST
  value: "datahub-datahub-svc"
- name: OGC_API_RECORDS_HOST
  value: "{{ include "georchestra.fullname" . }}-gn4-ogc-api-records-svc"
- name: ES_HOST
  value: "{{ include "georchestra.fullname" . }}-gn4-elasticsearch-svc"
- name: ES_PORT
  value: "9200"
- name: KB_HOST
  value: "{{ include "georchestra.fullname" . }}-gn4-kibana-svc"
- name: KB_PORT
  value: "5601"
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
