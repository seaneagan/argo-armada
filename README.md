# argo-armada

POC integration of [Armada](https://opendev.org/airship/armada) functionality into Airship 2 environment.

Runnable demos of using kustomize and argo workflow templates to deploy a set of
armada chart deployment specs. Certain workflow templates are either static or
generated via kustomize plugins depending on the demo. Workflow templates can be
run standalone via a simple wrapper, or invokved via a higher level workflow,
such as the Airship 2 `sitemanage` workflow, as a sub-step (single workflow UI).
The leaf tasks of the workflow invoke the armada [apply_chart entrypoint](https://review.opendev.org/#/q/topic:chart_entrypoint+(status:open+OR+status:merged)) (WIP).

# Dependencies:

* kubernetes e.g. [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
* [helm and tiller](https://v2.helm.sh/docs/using_helm/#quickstart)
* [argo](https://argoproj.github.io/docs/argo/demo.html) (need >= v2.5.0-rc6)

# Demos

## `make demo_groups_gen`

* Generates the workflow with an ArmadaWorkflow kustomize generator plugin
* Invokes Armada with ArmadaChart CRDs stored in the cluster

## `make demo_dag_gen`
* Same as previous, except:
* defines a DAG-based workflow

## `make demo_static_embedded`
* Completely static workflow template hierarchy
* Armada is invoked with classic Airship 1 style chart documents
* Chart documents are embedded into leaf workflow templates

## `make demo_static_secrets`
* Completely static workflow template hierarchy
* Armada is invoked with classic Airship 1 style chart documents
* Chart documents are stored in Secrets mounted into workflow templates
* NOTE: This doesn't work yet, depends on an [in-flight Argo feature](https://github.com/argoproj/argo/issues/2007)

## `make demo_static_custom_resources`
* Completely static workflow template hierarchy
* Armada is invoked with CRD chart documents

## `make demo_chart_gen`
* Example of using chart documents as kustomize generator input to generate
  leaf workflow templates to satisfy the chart. Could generate any of the above
  static examples using this approach

# Caveats

* In Airship 1, the Armada Helm chart placed tiller as a sidecar, this does not
  since it doesn't really make sense to have separate tillers for each separate
  armada CLI container.
