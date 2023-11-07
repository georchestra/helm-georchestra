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
