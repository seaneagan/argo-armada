{{- define "pull_template" -}}
  {{- $envAll := . -}}
  {{- $script := $envAll.Values.templates.pull.script -}}
  {{- $local := dict -}}
  {{- $workflow_spec := $envAll.Values.workflow.spec -}}
  {{-  $_ := set $local "charts" list -}}

  {{- range $chart := $workflow_spec.dag -}}
    {{-  $_ := set $local "charts" (append $local.charts $chart ) -}}
  {{- end -}}
  {{- range $group := $workflow_spec.groups -}}
    {{- range $chart := $group.charts -}}
      {{-  $_ := set $local "charts" (append $local.charts $chart ) -}}
    {{- end -}}
  {{- end -}}
script:
  image: {{ $envAll.Values.images.tags.kubectl }}
  command: [/bin/bash]
  volumeMounts:
    - name: pull-charts
      mountPath: /tmp/pull
  source: |
    set -x
    read -r -d '' charts <<'EOF'
    {{- range $chart := $local.charts }}
    {{ $chart.namespace }} {{ $chart.name }}
    {{- end }}
    EOF

    while read -r chart; do
      read -r namespace name <<<$(echo "$chart")
      chart_json=$(kubectl get armadacharts -n $namespace $name -o json)
      echo "$chart_json" > /tmp/pull/${namespace}_${name}
    done <<< "$charts"

{{- end -}}
