#!/bin/bash

export CHART_ROOT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/..

if [[ "${CLUSTER_NAME}xxx" == "xxx" ]];then
    CLUSTER_NAME="volcano-tryout"
fi

export CLUSTER_CONTEXT="--name ${CLUSTER_NAME}"

export KIND_OPT=${KIND_OPT:=" --config ${CHART_ROOT}/hack/e2e-kind-config.yaml"}

# check if kind installed
function check-prerequisites {
  echo "checking prerequisites"
  which kind >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "kind not installed, exiting."
    exit 1
  else
    echo -n "found kind, version: " && kind version
  fi

  which kubectl >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    echo "kubectl not installed, exiting."
    exit 1
  else
    echo -n "found kubectl, " && kubectl version --short --client
  fi
}

# spin up cluster with kind command
function kind-up-cluster {
  check-prerequisites
  echo "Running kind: [kind create cluster ${CLUSTER_CONTEXT} ${KIND_OPT}]"
  kind create cluster ${CLUSTER_CONTEXT} ${KIND_OPT}
}

function install-volcano {
  echo "Preparing helm tiller service account"
  kubectl create serviceaccount --namespace kube-system tiller
  kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller

  echo "Install helm via script and waiting tiller becomes ready"
  HELM_TEMP_DIR=`mktemp -d`
  curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > ${HELM_TEMP_DIR}/get_helm.sh
  #TODO: There are some issue with helm's latest version, remove '--version' when it get fixed.
  chmod 700 ${HELM_TEMP_DIR}/get_helm.sh && ${HELM_TEMP_DIR}/get_helm.sh   --version v2.13.0
  helm init --service-account tiller --kubeconfig ${KUBECONFIG} --wait

  echo "Pulling required docker images"
  docker pull ${IMAGE_PREFIX}-controllers:${TAG}
  docker pull ${IMAGE_PREFIX}-kube-batch:${TAG}
  docker pull ${IMAGE_PREFIX}-admission:${TAG}

  echo "Loading docker images into kind cluster"
  kind load docker-image ${IMAGE_PREFIX}-controllers:${TAG}  ${CLUSTER_CONTEXT}
  kind load docker-image ${IMAGE_PREFIX}-kube-batch:${TAG}  ${CLUSTER_CONTEXT}
  kind load docker-image ${IMAGE_PREFIX}-admission:${TAG}  ${CLUSTER_CONTEXT}

  echo "Install volcano chart"
  helm install chart/volcano --namespace kube-system --name ${CLUSTER_NAME} --kubeconfig ${KUBECONFIG} --set basic.image_tag_version=${TAG} --set basic.scheduler_config_file=kube-batch-ci.conf --wait
}

function uninstall-volcano {
  helm delete ${CLUSTER_NAME} --purge --kubeconfig ${KUBECONFIG}
}
# clean up
function cleanup {
  uninstall-volcano

  echo "Running kind: [kind delete cluster ${CLUSTER_CONTEXT}]"
  kind delete cluster ${CLUSTER_CONTEXT}
}

echo $* | grep -E -q "\-\-help|\-h"
if [[ $? -eq 0 ]]; then
  echo "Customize the kind-cluster name:

    export CLUSTER_NAME=<custom cluster name>  # default: integration

Customize kind options other than --name:

    export KIND_OPT=<kind options>
"
  exit 0
fi

trap cleanup EXIT

kind-up-cluster

export KUBECONFIG="$(kind get kubeconfig-path ${CLUSTER_CONTEXT})"

install-volcano
