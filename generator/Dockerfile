FROM lachlanevenson/k8s-helm:v2.16.1

WORKDIR /argo-armada-generator
ENTRYPOINT ["./argo-armada-generator"]
ENV PATH /argo-armada-generator:$PATH

COPY . ./
