#!/bin/bash

set -ex

# Check dependencies
kubectl version
helm version
argo version

PAUSE=${PAUSE:-true}

next_action() {
  ACTION=$1
  echo "Next action: $ACTION"
  if [ $PAUSE = "true" ]; then
    read -p "Press enter to continue..."
  fi
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

tree $DEMO

build() {
  EXAMPLE=$1
  next_action "generate and apply example '$EXAMPLE'"
  KUSTOMIZATION=$DIR/$EXAMPLE
  # See https://github.com/kubernetes/kubernetes/issues/44511
  # for why the namespace can't be included directly in the kustomization.
  kubectl apply -f $KUSTOMIZATION/namespace.yaml
  $DEMO/bin/kustomize build --reorder none --enable_alpha_plugins $KUSTOMIZATION | kubectl apply -f -
}

NAMESPACE=argo-armada-examples
RELEASE_PREFIX=argo-armada-examples

run_workflow_template() {
  WF_TEMPLATE=$1
  next_action "run generated workflow template '$WF_TEMPLATE'"
  WF=$(argo submit $DIR/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
  argo watch -n $NAMESPACE $WF
}

retry_last_workflow() {
  next_action "retry workflow '$WF'"
  WF=$(argo retry -o name -n $NAMESPACE $WF)
  argo watch -n $NAMESPACE $WF
}

show_last_workflow_results() {
  next_action "display helm releases (should be one for each chart)"
  helm ls | grep $RELEASE_PREFIX- || true

  next_action "display logs for single chart apply"
  POD=$(argo get -n $NAMESPACE $WF -o json | jq -r '.status.nodes | to_entries | map(select(.value.type == "Pod")) | map(.key)[0]')
  argo logs -n $NAMESPACE $POD

  next_action "display logs for full workflow"
  argo logs -n $NAMESPACE -w $WF
}

cleanup_last_workflow() {
  argo delete -n $NAMESPACE $WF
  for i in $(helm ls --short | grep $RELEASE_PREFIX-); do helm del --purge $i; done
}

build basic
# Delete a chart to force validation failure
kubectl delete -n argo-armada-examples armadacharts b2
# Run dag workflow (should fail)
run_workflow_template armadaworkflow-dag
# Re-sync documents to fix validation
build basic
# Retry workflow (should succeed now)
retry_last_workflow
show_last_workflow_results
cleanup_last_workflow

run_workflow_template armadaworkflow-groups
show_last_workflow_results
cleanup_last_workflow

# Cleanup
kubectl delete namespace $NAMESPACE
for i in $(kubectl get clusterroles -o name | grep armada); do kubectl delete $i; done
rm -rf $DEMO
