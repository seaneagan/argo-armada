{{- define "convert_template" -}}
  {{- $envAll := . -}}
  {{- $container := $envAll.Values.convert.container -}}
  {{- $local := dict -}}
  {{-  $_ := set $local "charts" list -}}

  {{- range $chart := $envAll.Values.dag -}}
    {{-  $_ := set $local "charts" (append $local.charts $chart.name ) -}}
  {{- end -}}
  {{- range $group := $envAll.Values.groups -}}
    {{- range $chart := $group -}}
      {{-  $_ := set $local "charts" (append $local.charts $chart ) -}}
    {{- end -}}
  {{- end -}}
name: convert
script:
{{ $container | toYaml | indent 2 }}
  volumeMounts:
    - name: converted
      mountPath: /tmp/converted
  source: |
  {{- range $chart := $local.charts }}
    chart_json=$(kubectl get armadacharts {{ $chart }} -o json)
    converted_chart_json=$(echo "$chart_json" | jq '. + {"data": .spec} | del(.spec)')
    chart_file=/tmp/converted/{{ $chart }}
    echo "$converted_chart_json" > "$chart_file"
  {{- end }}
{{- end -}}
