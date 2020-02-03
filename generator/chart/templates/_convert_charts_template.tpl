{{- define "convert_charts_template" -}}
  {{- $envAll := . -}}
script:
  image: {{ $envAll.Values.conf.images.tags.jq }}
  command: [/bin/sh]
  volumeMounts:
    - name: pulled-charts
      mountPath: /tmp/pull
    - name: converted-charts
      mountPath: /tmp/convert
  source: |
    set -x
    for crd_file in /tmp/pull/*; do
      [ -e "$crd_file" ] || continue
      chart_json=$(cat "$crd_file")
      # 1. Rename `spec` to `data`
      # 2. Add `schema`
      convert_chart_json=$(echo "$chart_json" | jq '. + {"data": .spec} | del(.spec) | . + {"schema": "armada/Chart/v2"}')
      chart_file=/tmp/convert/$(basename $crd_file)
      echo "$convert_chart_json" > "$chart_file"
    done
{{- end -}}
