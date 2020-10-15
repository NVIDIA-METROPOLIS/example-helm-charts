{{- define "imagePullSecret" }}
{{- printf "{\"auths\": {\"%s\": {\"auth\": \"%s\"}}}" .global.nvidia.docker.registry (printf "%s:%s" .global.nvidia.docker.username .global.nvidia.docker.password | b64enc) | b64enc }}
{{- end }}
