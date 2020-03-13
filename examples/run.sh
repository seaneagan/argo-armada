#!/bin/bash

set -ex

PLUGIN=$1
EXAMPLE=$2
WF_TEMPLATE=$3
PAUSE=${PAUSE:-true}

# Check dependencies
kubectl version
# helm version
argo version

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

if [ ! -z $PLUGIN ]; then
  $DIR/../install_plugin.sh $PLUGIN
fi

build() {
  next_action "generate and apply example '$EXAMPLE'"
  KUSTOMIZATION=$DIR/$EXAMPLE
  # See https://github.com/kubernetes/kubernetes/issues/44511
  # for why the namespace can't be included directly in the kustomization.
  kubectl apply -f $DIR/common/namespace.yaml
  $DEMO/bin/kustomize build --reorder none --enable_alpha_plugins --load_restrictor LoadRestrictionsNone $KUSTOMIZATION | tee >(kubectl apply -f -)
}

NAMESPACE=argo-armada-examples
RELEASE_PREFIX=argo-armada-examples

run_workflow_template() {
  next_action "run workflow template '$WF_TEMPLATE'"
  WF=$(argo submit $DIR/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
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

build
run_workflow_template
show_last_workflow_results
cleanup_last_workflow

# Cleanup
kubectl delete namespace $NAMESPACE
for i in $(kubectl get clusterroles -o name | grep armada); do kubectl delete $i; done
rm -rf $DEMO
