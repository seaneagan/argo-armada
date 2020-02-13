# argo-armada

POC integration of [Armada](https://opendev.org/airship/armada) functionality into Airship 2 environment.

# Features

* Integrates with the armada [chart entrypoint and CRD](https://review.opendev.org/#/q/topic:chart_entrypoint+(status:open+OR+status:merged)) (WIP)
* Defines a workflow CRD which:
  * replaces Airship 1 `armada/Manifest/v2` and `armada/ChartGroup/v2` schema docs
  * adds DAG support
* Defines static Argo workflow template which:
  * consumes these CRs
  * can be run standalone
  * can be called from Airship 2 `sitemanage` workflow, as a sub-step (single workflow UI)
  * decomposes each chart installation into its own task for improved visibility
* Defines appropriate RBAC roles to run the above template

# Dependencies:

* kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [helm and tiller](https://v2.helm.sh/docs/using_helm/#quickstart)
* [argo](https://argoproj.github.io/docs/argo/demo.html) (need >= v2.5.0-rc6)

# Demo

```bash
# Create a demo workspace
DEMO=$(mktemp -d)

# Install kustomize
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
mkdir -p $DEMO/bin
mv kustomize $DEMO/bin

# Install plugin
PLUGIN_ROOT=$DEMO/kustomize/plugin
PLUGIN_DIR=$PLUGIN_ROOT/armada.airshipit.org/v1alpha1/armadaworkflow
mkdir -p $PLUGIN_DIR
cp -R generator/. $PLUGIN_DIR

# Create a kustomization
KUSTOMIZATION=$DEMO/kustomization
mkdir -p $KUSTOMIZATION

# Add base
BASE=$KUSTOMIZATION/base
mkdir -p $BASE
cp -R manifests/. $BASE

# Add armadachart CRD
# TODO: Convert to kustomization
kubectl apply -f "https://review.opendev.org/gitweb?p=airship/armada.git;a=blob_plain;f=apis/chart.yaml;hb=refs/changes/67/706967/1"

# Add examples
cp -R examples/. $KUSTOMIZATION

# Build and apply examples
XDG_CONFIG_HOME=$DEMO $DEMO/bin/kustomize build --enable_alpha_plugins $KUSTOMIZATION | kubectl apply -f -

# Run examples
argo submit armada-workflow.yaml --watch --serviceaccount armada -p name=armada-workflow-dag
argo submit armada-workflow.yaml --watch --serviceaccount armada -p name=armada-workflow-groups
```

# Caveats

* In Airship 1, the Armada Helm chart placed tiller as a sidecar, this does not
  since it doesn't really make sense to have separate tillers for each separate
  armada CLI container.
