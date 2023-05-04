#!/usr/bin/env bash

# The script was originally found here https://github.com/fluxcd/flux2-kustomize-helm-example/blob/main/scripts/validate.sh and sligltly adapted

# This script downloads the Flux OpenAPI schemas, then it validates the
# Flux custom resources and the kustomize overlays using kubeconform.
# This script is meant to be run locally and in CI before the changes
# are merged on the main branch that's synced by Flux.

# Copyright 2022 The Flux authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script is meant to be run locally and in CI to validate the Kubernetes
# manifests (including Flux custom resources) before changes are merged into
# the branch synced by Flux in-cluster.

# Prerequisites
# - yq v4.30
# - kustomize v4.5
# - kubeconform v0.5.0

set -o errexit

echo "INFO - Downloading Flux OpenAPI schemas"
mkdir -p /tmp/flux-crd-schemas/master-standalone-strict
curl -sL https://github.com/fluxcd/flux2/releases/latest/download/crd-schemas.tar.gz | tar zxf - -C /tmp/flux-crd-schemas/master-standalone-strict

echo "-----------------------------------------------------"
echo "INFO - validating yaml files"

for YAML_FILE in $(find . -type f -name "*.yaml" -or -name "*.yml"); do
  YAML_DIR="$(dirname "${YAML_FILE}")"
  if [[ $3 == "__ALL__" || $3 == *"${YAML_DIR:2}"* ]]; then # check if the directory is in the target directories
    echo "INFO - Validating $YAML_FILE"
    yq e 'true' "$YAML_FILE" > /dev/null
  fi
done

KUBECONFORM_CONFIG="-strict -ignore-missing-schemas -schema-location default -schema-location /tmp/flux-crd-schemas"

if [ $1 = "true" ]; then
  KUBECONFORM_CONFIG="$KUBECONFORM_CONFIG -verbose"
fi


# echo "-----------------------------------------------------"
# echo "INFO - running kubeconform on $2"

# for CLUSTER_FILE in $(find $2 -maxdepth 2 -type d); do
#   echo "INFO - Validating $CLUSTER_FILE"
#   kubeconform $KUBECONFORM_CONFIG $CLUSTER_FILE
# done

# mirror kustomize-controller build options
KUSTOMIZE_FLAG="--load-restrictor=LoadRestrictionsNone"
KUSTOMIZE_CONFIG="kustomization"

echo "-----------------------------------------------------"
echo "INFO - running kubeconform on kustomize build output"

for KUSTOMIZATION_FILE in $(find . -type f -name $KUSTOMIZE_CONFIG.yaml -or -name $KUSTOMIZE_CONFIG.yml); do
  KUSTOMIZATION_DIR="$(dirname "${KUSTOMIZATION_FILE}")"
  if [[ $3 == "__ALL__" || $3 == *"${KUSTOMIZATION_DIR:2}"* ]]; then # check if the directory is in the target directories
    echo "INFO - Validating kustomization $KUSTOMIZATION_FILE"
    kustomize build $KUSTOMIZATION_DIR $KUSTOMIZE_FLAG | kubeconform $KUBECONFORM_CONFIG
  fi
done
