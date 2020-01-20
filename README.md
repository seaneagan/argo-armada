# argo-armada

Exploration of using Argo to implement [Armada](https://opendev.org/airship/armada) workflows.

# Demo

1. Install dependencies:
    * kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
    * [tiller](https://v2.helm.sh/docs/using_helm/#quickstart)
    * [argo](https://argoproj.github.io/docs/argo/demo.html)
1. Install manifests (CRDs, workflow templates, etc):
    * `kubectl apply -f manifests -R`
1. Install example CRs:
    * `namespace=default`
    * `kubectl apply -n $namespace -f examples -R`
1. Run example CRs:
    * `argo submit armada-workflow.yaml --watch -f parameter-defaults.yaml -p namespace=$namespace -p name=dag`
    * `argo submit armada-workflow.yaml --watch -f parameter-defaults.yaml -p namespace=$namespace -p name=groups`

# Proposed airshipctl integration

The workflow template in `manifests/armada-workflow-template.yaml` would be
called by the airshipctl `sitemanage` workflow. Could also add a `softwaremanage`
workflow if desired, similar to the `update_site` / `update_software` workflows
in Airship 1.
