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
