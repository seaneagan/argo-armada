{{- define "task_template" -}}
{{- $envAll := . -}}
{{- $task_template := $envAll.Values.task_template -}}
name: deploy-chart
inputs:
  parameters:
  - name: chart
container:
{{ $task_template.container | toYaml | indent 2 }}
  args:
    - armada
    - apply_chart
    - --release_prefix={{ $task_template.release_prefix }}
    - "{{ "{{inputs.parameters.chart}}" }}"
{{- end -}}
