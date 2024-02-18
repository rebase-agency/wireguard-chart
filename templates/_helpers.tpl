{{/*
Expand the name of the chart.
*/}}
{{- define "wireguard.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "wireguard.fullname" -}}
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
{{- define "wireguard.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "wireguard.labels" -}}
helm.sh/chart: {{ include "wireguard.chart" . }}
{{ include "wireguard.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "wireguard.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wireguard.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "wireguard.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "wireguard.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the network policy to use
*/}}
{{- define "wireguard.networkPolicyName" -}}
{{- if .Values.networkPolicy.create }}
{{- default (include "wireguard.fullname" .) .Values.networkPolicy.name }}
{{- else }}
{{- default "default" .Values.networkPolicy.name }}
{{- end }}
{{- end }}

{{/*
Create annotations for the DigitalOcean load balancer
*/}}
{{- define "wireguard.doLoadBalancerAnnotations" -}}
service.beta.kubernetes.io/do-loadbalancer-healthcheck-check-interval-seconds: '3'
service.beta.kubernetes.io/do-loadbalancer-healthcheck-healthy-threshold: '5'
service.beta.kubernetes.io/do-loadbalancer-healthcheck-port: {{ .Values.echoServer.service.port | quote }}
service.beta.kubernetes.io/do-loadbalancer-healthcheck-protocol: 'tcp'
service.beta.kubernetes.io/do-loadbalancer-healthcheck-response-timeout-seconds: '4'
service.beta.kubernetes.io/do-loadbalancer-healthcheck-unhealthy-threshold: '3'
{{- end }}

{{/*
Create wireguard service annotations
*/}}
{{- define "wireguard.serviceAnnotations" -}}
{{- if and (eq .Values.wireguard.service.type "LoadBalancer") (contains "DigitalOcean" .Values.wireguard.service.provider) }}
{{- include "wireguard.doLoadBalancerAnnotations" . }}
{{- end }}
{{- with .Values.wireguard.service.annotations }}
{{- toYaml . | nindent 0 }}
{{- end }}
{{- end }}

{{/*
Calculate subnet of the wireguard server
*/}}
{{- define "wireguard.serverAddressSubnet" -}}
{{- $subnet := .Values.wireguard.subnet -}}
{{- $split := (split "/" $subnet) -}}
{{- $ip := $split._0 -}}
{{- $ip_octets := (split "." $ip) -}}
{{- $serverAddress := printf "%s.%s.%s.%s" ($ip_octets._0) ($ip_octets._1) ($ip_octets._2) "1" -}}
{{- $serverAddressSubnet := printf "%s/%s" $serverAddress ($split._1) -}}
{{- $serverAddressSubnet -}}
{{- end }}