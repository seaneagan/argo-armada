ARG CURL_IMAGE=byrnedo/alpine-curl
ARG HELM_CLI_IMAGE=lachlanevenson/k8s-helm:v2.16.1
FROM ${CURL_IMAGE} AS curl
ARG KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/v1.17.2/bin/linux/amd64/kubectl
RUN curl -LO "${KUBECTL_URL}" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

FROM ${HELM_CLI_IMAGE}

WORKDIR /argo-armada-generator
ENTRYPOINT ["./argo-armada-generator"]
ENV PATH /argo-armada-generator:$PATH

COPY --from=curl /usr/local/bin/kubectl /usr/local/bin/kubectl

COPY . ./
