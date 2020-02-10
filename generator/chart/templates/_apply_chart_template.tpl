{{- define "apply_chart_template" -}}
{{- $envAll := . -}}
inputs:
  parameters:
  - name: namespace
  - name: name
script:
  image: {{ $envAll.Values.conf.images.tags.armada | quote }}
  command: [/bin/sh]
  source: |
    set -x
    armada apply_chart --release-prefix={{ $envAll.Values.conf.release_prefix }} "kube:armadacharts/{{ "{{inputs.parameters.namespace}}" }}/{{ "{{inputs.parameters.name}}" }}"
{{- end -}}
