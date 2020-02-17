#!/bin/bash

set -ex

pause() {
  read -p "Press enter to: $1"
}

# Create a demo workspace
DEMO=$(mktemp -d)

export XDG_CONFIG_HOME=$DEMO

# Install kustomize
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mkdir -p $DEMO/bin
mv kustomize $DEMO/bin

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
$DIR/../install_plugin.sh

# Create a kustomization
KUSTOMIZATION=$DEMO/kustomization
mkdir -p $KUSTOMIZATION

# Add base
BASE=$KUSTOMIZATION/base
mkdir -p $BASE
cp -R base/. $BASE

# Add examples
cp -R examples/. $KUSTOMIZATION

tree $DEMO

pause "generate and apply workflow templates"

# Build and apply examples
$DEMO/bin/kustomize build --enable_alpha_plugins $KUSTOMIZATION | kubectl apply -f -

run_example() {
  WF_TEMPLATE=$1
  echo Running example for workflow template $WF_TEMPLATE...

  pause "display example helm releases (should be none)"
  helm ls | grep argo-armada-examples- || true

  pause "run generated workflow template '$WF_TEMPLATE'"
  WF1=$(argo submit examples/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
  argo watch -n argo-armada-examples $WF1

  pause "display helm releases (should be one for each chart)"
  helm ls | grep argo-armada-examples- || true

  pause "display logs for single chart apply"
  POD1=$(argo get -n argo-armada-examples $WF1 -o json | jq -r '.status.nodes | to_entries | map(select(.value.type == "Pod")) | map(.key)[0]')
  argo logs -n argo-armada-examples $POD1

  pause "display logs for full workflow"
  argo logs -n argo-armada-examples -w $WF1

  pause "run generated workflow template '$WF_TEMPLATE' again to check idempotency"
  WF2=$(argo submit examples/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
  argo watch -n argo-armada-examples $WF2

  pause "display helm releases (should be one release for each chart, no updates)"
  helm ls | grep argo-armada-examples- || true

  # Cleanup
  argo delete -n argo-armada-examples $WF1 $WF2
  for i in $(helm ls --short | grep "argo-armada-examples-"); do helm del --purge $i; done
}

# Run examples
run_example armada-workflow-dag
run_example armada-workflow-groups

# Cleanup
kubectl delete namespace argo-armada-examples
for i in $(kubectl get clusterroles -o name | grep armada); do kubectl delete $i; done
rm -rf $DEMO
