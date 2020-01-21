#!/bin/bash
set -x

PROXY_ARGS=""
if [[ "${USE_PROXY}" == true ]]; then
  PROXY_ARGS="--build-arg http_proxy=${PROXY} \
    --build-arg https_proxy=${PROXY} \
    --build-arg HTTP_PROXY=${PROXY} \
    --build-arg HTTPS_PROXY=${PROXY} \
    --build-arg no_proxy=${NO_PROXY} \
    --build-arg NO_PROXY=${NO_PROXY}"
fi

docker build --network host -t ${IMAGE} \
  --label org.opencontainers.image.revision=${COMMIT} \
  --label org.opencontainers.image.created="$(date --rfc-3339=seconds --utc)" \
  --label org.opencontainers.image.title=${IMAGE_NAME} \
  ${PROXY_ARGS} \
  -f generator/Dockerfile generator
