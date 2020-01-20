{{- define "apply_chart_template" -}}
{{- $envAll := . -}}
inputs:
  parameters:
  - name: chart-path
script:
  image: {{ "{{ $envAll.Values.images.tags.armada }}" | quote }}
  command: [/bin/sh]
  volumeMounts:
    - name: converted-charts
      mountPath: /tmp/convert
  source: |
    set -x
    armada apply_chart --release-prefix={{ $envAll.Values.release_prefix }} "/tmp/convert/{{ "{{inputs.parameters.chart-path}}" }}"
{{- end -}}
