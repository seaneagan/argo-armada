#!/bin/bash

set -ex

# Create a demo workspace
DEMO=$(mktemp -d)

export XDG_CONFIG_HOME=$DEMO

# Install kustomize
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash
mkdir -p $DEMO/bin
mv kustomize $DEMO/bin

# Install plugin
PLUGIN_ROOT=$XDG_CONFIG_HOME/kustomize/plugin
PLUGIN_DIR=$PLUGIN_ROOT/armada.airshipit.org/v1alpha1/armadaworkflow
mkdir -p $PLUGIN_DIR
cp -R generator/. $PLUGIN_DIR

# Install plugin-local helm 3 cli for ArmadaWorkflow schema validation (optional)
curl https://get.helm.sh/helm-v3.1.0-linux-amd64.tar.gz -o $DEMO/helm3.tar.gz
tar -zxvf $DEMO/helm3.tar.gz --directory $DEMO
mv $DEMO/linux-amd64/helm $PLUGIN_DIR/helm

# Create a kustomization
KUSTOMIZATION=$DEMO/kustomization
mkdir -p $KUSTOMIZATION

# Add base
BASE=$KUSTOMIZATION/base
mkdir -p $BASE
cp -R base/. $BASE

# Add armadachart CRD
# TODO: Convert to kustomization
kubectl apply -f "https://review.opendev.org/gitweb?p=airship/armada.git;a=blob_plain;f=apis/chart.yaml;hb=refs/changes/67/706967/1"

# Add examples
cp -R examples/. $KUSTOMIZATION

# Build and apply examples
$DEMO/bin/kustomize build --enable_alpha_plugins $KUSTOMIZATION | kubectl apply -f -

run_example() {
  WF_TEMPLATE=$1

  echo Before:
  echo
  helm ls | grep argo-armada-examples- || true

  WF1=$(argo submit examples/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
  argo watch -n argo-armada-examples $WF1

  echo After:
  echo
  helm ls | grep argo-armada-examples- || true

  echo Display logs for single chart apply:
  echo
  POD1=$(argo get -n argo-armada-examples $WF1 -o json | jq -r '.status.nodes | to_entries | map(select(.value.type == "Pod")) | map(.key)[0]')
  argo logs -n argo-armada-examples $POD1

  echo Display logs for all chart applies:
  echo
  argo logs -n argo-armada-examples -w $WF1

  echo Run again to check idempotency:
  echo
  WF2=$(argo submit examples/armada-workflow.yaml -o name --serviceaccount armada -p name=$WF_TEMPLATE)
  argo watch -n argo-armada-examples $WF2

  # Display logs for single chart apply
  POD2=$(argo get -n argo-armada-examples $WF2 -o json | jq -r '.status.nodes | to_entries | map(select(.value.type == "Pod")) | map(.key)[0]')
  argo logs -n argo-armada-examples $POD2

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
