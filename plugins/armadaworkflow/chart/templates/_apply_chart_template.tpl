{{- define "apply_chart_template" -}}
{{- $envAll := . -}}
inputs:
  parameters:
  - name: namespace
  - name: name
script:
  image: {{ $envAll.Values.workflow.spec.apply_chart.image | quote }}
  command: [/bin/sh]
  source: |
    set -x
    armada apply_chart --release-prefix={{ $envAll.Values.workflow.spec.release_prefix }} "kube:armadacharts/{{ "{{inputs.parameters.namespace}}" }}/{{ "{{inputs.parameters.name}}" }}"
{{- end -}}
