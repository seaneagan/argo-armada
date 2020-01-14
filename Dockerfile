FROM lachlanevenson/k8s-helm:v2.16.1

COPY charts/argo_armada_workflow /opt/app/argo-armada/charts/argo_armada_workflow
