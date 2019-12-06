# argo-armada

Exploration of using Argo to implement [Armada](https://opendev.org/airship/armada) workflows.

# Demo

1. Install dependencies:
    * kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
    * [helm](https://helm.sh/docs/intro/install)
    * [argo](https://argoproj.github.io/docs/argo/demo.html)
1. Install CRDs:
    * `kubectl apply -f apis`
1. Install example CRs:
    * `kubectl apply -f examples`
1. Run examples:
    * `./armada-workflow default dag`
    * `./armada-workflow default groups`
