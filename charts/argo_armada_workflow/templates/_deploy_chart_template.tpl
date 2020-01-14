{{- define "deploy_chart_template" -}}
{{- $envAll := . -}}
inputs:
  parameters:
  - name: namespace
  - name: name
script:
  image: {{ $envAll.Values.images.tags.armada }}
  command: [/bin/sh]
  volumeMounts:
    - name: convert-charts
      mountPath: /tmp/convert
  source: |
    set -x
    armada apply_chart --release-prefix={{ $envAll.Values.release_prefix }} "/tmp/convert/{{ "{{inputs.parameters.namespace}}_{{inputs.parameters.name}}" }}"
{{- end -}}
