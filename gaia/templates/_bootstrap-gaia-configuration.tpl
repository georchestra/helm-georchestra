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
