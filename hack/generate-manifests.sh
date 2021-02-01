#!/usr/bin/env bash

set -eo pipefail
set -x

SRCROOT="$( CDPATH='' cd -- "$(dirname "$0")/.." && pwd -P )"

AUTOGENMSG="# This is an auto-generated file. DO NOT EDIT"



KUSTOMIZE=${KUSTOMIZE:-kustomize}

TEMPFILE=$(mktemp /tmp/appset-manifests.XXXXXX)

if [ "$CONTAINER_REGISTRY" != "" ]; then
	CONTAINER_REGISTRY="${CONTAINER_REGISTRY}/"
fi


IMAGE_NAMESPACE="${IMAGE_NAMESPACE:-argoprojlabs}"
IMAGE_TAG="${IMAGE_TAG:-}"

# if the tag has not been declared, and we are on a release branch, use the VERSION file.
if [ "$IMAGE_TAG" = "" ]; then
  branch=$(git rev-parse --abbrev-ref HEAD || true)
  if [[ $branch = release-* ]]; then
    pwd
    IMAGE_TAG=v$(cat $SRCROOT/VERSION)
  fi
fi
# otherwise, use latest
if [ "$IMAGE_TAG" = "" ]; then
  IMAGE_TAG=latest
fi

cd ${SRCROOT}/manifests/base && ${KUSTOMIZE} edit set image argoprojlabs/argocd-applicationset=${CONTAINER_REGISTRY}${IMAGE_NAMESPACE}/argocd-applicationset:${IMAGE_TAG}

echo "${AUTOGENMSG}" > ${TEMPFILE}
cd ${SRCROOT}/manifests/namespace-install && ${KUSTOMIZE} build . >> ${TEMPFILE}

mv ${TEMPFILE} ${SRCROOT}/manifests/install.yaml
cd ${SRCROOT} && chmod 644 manifests/install.yaml