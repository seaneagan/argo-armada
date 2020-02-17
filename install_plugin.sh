#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Install plugin
PLUGIN_ROOT=$XDG_CONFIG_HOME/kustomize/plugin
PLUGIN_DIR=$PLUGIN_ROOT/armada.airshipit.org/v1alpha1/armadaworkflow
mkdir -p $PLUGIN_DIR
cp -R $DIR/generator/. $PLUGIN_DIR

# Install plugin-local helm 3 cli for ArmadaWorkflow schema validation (optional)
DOWNLOAD_CONTAINER=$PLUGIN_DIR/helm_download
mkdir -p $DOWNLOAD_CONTAINER
DOWNLOAD_TARGET=$DOWNLOAD_CONTAINER/helm.tar.gz
ARCH=linux-amd64
curl https://get.helm.sh/helm-v3.1.0-$ARCH.tar.gz -o $DOWNLOAD_TARGET
tar -zxvf $DOWNLOAD_TARGET --directory $DOWNLOAD_CONTAINER
mv $DOWNLOAD_CONTAINER/$ARCH/helm $PLUGIN_DIR/helm
rm -rf $DOWNLOAD_CONTAINER
