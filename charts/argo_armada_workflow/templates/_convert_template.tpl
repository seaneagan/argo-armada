{{- define "convert_template" -}}
  {{- $envAll := . -}}
  {{- $script := $envAll.Values.templates.convert.script -}}
script:
  image: {{ $envAll.Values.images.tags.jq }}
  command: [/bin/sh]
  volumeMounts:
    - name: pull-charts
      mountPath: /tmp/pull
    - name: convert-charts
      mountPath: /tmp/convert
  source: |
    set -x
    for crd_file in /tmp/pull/*; do
      [ -e "$crd_file" ] || continue
      chart_json=$(cat "$crd_file")
      convert_chart_json=$(echo "$chart_json" | jq '. + {"data": .spec} | . + {"schema": "armada/Chart/v2"} | del(.spec)')
      chart_file=/tmp/convert/$(basename $crd_file)
      echo "$convert_chart_json" > "$chart_file"
    done
{{- end -}}
