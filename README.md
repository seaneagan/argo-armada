# argo-armada

POC integration of [Armada](https://opendev.org/airship/armada) functionality into Airship 2 environment.

# Description

* defines a kustomize generator plugin which:
  * takes a configuration schema which:
    * collapses Airship 1 `armada/Manifest/v2` and `armada/ChartGroup/v2` schemas
    * supports DAGs or explicit groups of charts
  * generates an argo workflow template which:
    * can be run standalone
    * can be called from Airship 2 `sitemanage` workflow, as a sub-step (single workflow UI)
    * spawns tasks for each chart installation which:
      * call the armada [apply_chart entrypoint with armadachart CRDs](https://review.opendev.org/#/q/topic:chart_entrypoint+(status:open+OR+status:merged)) (WIP)

# Dependencies:

* kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [helm and tiller](https://v2.helm.sh/docs/using_helm/#quickstart)
* [argo](https://argoproj.github.io/docs/argo/demo.html) (need >= v2.5.0-rc6)

# Demo

`make demo`

# Caveats

* In Airship 1, the Armada Helm chart placed tiller as a sidecar, this does not
  since it doesn't really make sense to have separate tillers for each separate
  armada CLI container.
