{{/*
Expand the name of the chart.
*/}}
{{- define "helm-gaia.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "helm-gaia.fullname" -}}
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
{{- define "helm-gaia.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "helm-gaia.labels" -}}
helm.sh/chart: {{ include "helm-gaia.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "helm-gaia.selectorLabels" -}}
app.kubernetes.io/name: {{ include "helm-gaia.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "helm-gaia.selectorLabelsCelery" -}}
app.kubernetes.io/name: {{ include "helm-gaia.name" . }}-gaia-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "helm-gaia.selectorLabelsBack" -}}
app.kubernetes.io/name: {{ include "helm-gaia.name" . }}-gaia
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "helm-gaia.selectorLabelsRedis" -}}
app.kubernetes.io/name: {{ include "helm-gaia.name" . }}-gaia-redis
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "helm-gaia.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "helm-gaia.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
