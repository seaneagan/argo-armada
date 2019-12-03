# argo-armada

Exploration of using Argo to implement [Armada](https://opendev.org/airship/armada) workflows.

# Demo

1. Install dependencies:
    * kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
    * [helm](https://helm.sh/docs/intro/install)
    * [argo](https://argoproj.github.io/docs/argo/demo.html)
1. Install CRD:
    * `kubectl apply -f apis/workflow.yaml`
1. Install example CRs:
    * `kubectl apply -f examples`
1. Run examples:
    * `./armada-workflow default examples/dag.yaml`
    * `./armada-workflow default examples/groups.yaml`
