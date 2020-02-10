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

# Demo

1. Install dependencies:
    * kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
    * [tiller](https://v2.helm.sh/docs/using_helm/#quickstart)
    * [argo](https://argoproj.github.io/docs/argo/demo.html) (need >= v2.5.0-rc6)
1. Install manifests (CRDs, workflow templates, etc):
    * `kubectl create namespace argo-armada`
    * `kubectl apply -f manifests -R`
    * `kubectl apply -f "https://review.opendev.org/gitweb?p=airship/armada.git;a=blob_plain;f=apis/chart.yaml;hb=refs/changes/67/706967/1"`
1. Install example CRs:
    * `kubectl create namespace argo-armada-examples`
    * `kubectl apply -f examples -R`
1. Run example CRs:
    * `argo submit armada-workflow.yaml --watch --serviceaccount armada -p namespace=argo-armada-examples -p name=dag`
    * `argo submit armada-workflow.yaml --watch --serviceaccount armada -p namespace=argo-armada-examples -p name=groups`

# Implementation

`armada-workflow.yaml` receives `namespace` and `name` parameters to identify
which armada workflow CR (stored in the cluster) to apply. It passes them to
`manifests/armada-workflow-template.yaml` which is an argo workflow template,
which looks up the armada workflow CR and generates an argo workflow template
from it, using the container image and embedded Helm chart defined in
`generator`. This generated workflow template is then invoked as the last step,
utilizing the workflow template `runtimeResolution: true` option. The generated
workflow template tasks invokes the armada `apply_chart` entrypoint for each
referenced armada chart CR.

# Caveats

* In Airship 1, the Armada Helm chart placed tiller as a sidecar, this does not
  since it doesn't really make sense to have separate tillers for each separate
  armada CLI container.
