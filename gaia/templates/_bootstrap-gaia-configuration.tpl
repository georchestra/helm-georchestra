{{- define "gaia.bootstrap_gaia_configuration" -}}
- name: bootstrap-gaia-configuration
  image: "{{ .Values.datadir.image.repository }}:{{ .Values.datadir.image.tag }}"
  command:
  - /bin/sh
  - -c
  - {{- if .Values.datadir.git.ssh_secret }}
    mkdir -p /root/.ssh ;
    cp /ssh-secret/ssh-privatekey /root/.ssh/id_rsa ;
    chmod 0600 /root/.ssh/id_rsa ;
    {{- end }}
    rm -Rf /etc/georchestra ;
    git clone --depth 1 --single-branch {{ .Values.datadir.git.url }} -b {{ .Values.datadir.git.ref }} /etc/georchestra ;
  {{- if .Values.datadir.git.ssh_secret }}
  env:
    - name: GIT_SSH_COMMAND
      value: ssh -o "IdentitiesOnly=yes" -o "StrictHostKeyChecking no"
  {{- end }}
  volumeMounts:
  - mountPath: /etc/georchestra
    name: georchestra-datadir
  {{- if .Values.datadir.git.ssh_secret }}
  - mountPath: /ssh-secret
    name: ssh-secret
  {{- end }}
{{- end -}}

{{/*
Insert database environment variables
*/}}
{{- define "gaia.bootstrap_gaia_database_envs" -}}
{{- if .Values.database.auth.existingSecret }}
{{- $secret_name := .Values.database.auth.existingSecret -}}
- name: PGHOST
  valueFrom:
    secretKeyRef:
        name: {{ $secret_name }}
        key: host
        optional: false
- name: PGPORT
  valueFrom:
    secretKeyRef:
        name: {{ $secret_name }}
        key: port
        optional: false
- name: PGDATABASE
  valueFrom:
    secretKeyRef:
        name: {{ $secret_name }}
        key: dbname
        optional: false
- name: PGUSER
  valueFrom:
    secretKeyRef:
        name: {{ $secret_name }}
        key: user
        optional: false
- name: PGPASSWORD
  valueFrom:
    secretKeyRef:
        name: {{ $secret_name }}
        key: password
        optional: false
{{- else }}
- name: PGHOST
  value: "{{ .Values.database.auth.host }}"
- name: PGPORT
  value: "{{ .Values.database.auth.port }}"
- name: PGDATABASE
  value: "{{ .Values.database.auth.database }}"
- name: PGUSER
  value: "{{ .Values.database.auth.username }}"
- name: PGPASSWORD
  value: "{{ .Values.database.auth.password }}"
{{- end }}
{{- end }}

{{/*
Insert service host environment variables
*/}}
{{- define "gaia.service-envs" -}}
- name: FQDN
  value: "{{ .Values.georchestra.fqdn }}"
- name: ANALYTICS_HOST
  value: "{{ .Values.georchestra.fullname }}-analytics-svc"
- name: CAS_HOST
  value: "{{ .Values.georchestra.fullname }}-cas-svc"
- name: CONSOLE_HOST
  value: "{{ .Values.georchestra.fullname }}-console-svc"
- name: GEONETWORK_HOST
  value: "{{ .Values.georchestra.fullname }}-geonetwork-svc"
- name: GEOSERVER_HOST
  value: "{{ .Values.georchestra.fullname }}-geoserver-svc"
- name: HEADER_HOST
  value: "{{ .Values.georchestra.fullname }}-header-svc"
- name: GEOWEBCACHE_HOST
  value: "{{ .Values.georchestra.fullname }}-geowebcache-svc"
- name: MAPSTORE_HOST
  value: "{{ .Values.georchestra.fullname }}-mapstore-svc"
- name: DATAFEEDER_HOST
  value: "{{ .Values.georchestra.fullname }}-datafeeder-svc"
- name: IMPORT_HOST
  value: "{{ .Values.georchestra.fullname }}-import-svc"
- name: DATAHUB_HOST
  value: "datahub-datahub-svc"
- name: OGC_API_RECORDS_HOST
  value: "{{ .Values.georchestra.fullname }}-gn4-ogc-api-records-svc"
- name: ES_HOST
  value: "{{ .Values.georchestra.fullname }}-gn4-elasticsearch-svc"
- name: ES_PORT
  value: "9200"
- name: KB_HOST
  value: "{{ .Values.georchestra.fullname }}-gn4-kibana-svc"
- name: KB_PORT
  value: "5601"
{{- end }}
