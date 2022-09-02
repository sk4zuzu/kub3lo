#!/usr/bin/env bash

: "${SUC_VERSION:=0.9.1}"
: "${K3S_VERSION:=v1.24.4+k3s1}"

set -o errexit -o nounset -o pipefail

kubectl apply -f "https://github.com/rancher/system-upgrade-controller/releases/download/v${SUC_VERSION}/system-upgrade-controller.yaml"

for RETRY in 9 8 7 6 5 4 3 2 1 0; do
  if kubectl get crd/plans.upgrade.cattle.io --no-headers; then break; fi
  sleep 5
done && [[ "$RETRY" -gt 0 ]]

kubectl apply -f- <<EOF
---
# Server plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: server-plan
  namespace: system-upgrade
  labels:
    k3s-upgrade: server
spec:
  concurrency: 1
  nodeSelector:
    matchExpressions:
       - {key: k3s-upgrade, operator: Exists}
       - {key: k3s-upgrade, operator: NotIn, values: ["disabled", "false"]}
       # When using k8s version 1.19 or older, swap control-plane with master
       - {key: node-role.kubernetes.io/control-plane, operator: In, values: ["true"]}
  serviceAccountName: system-upgrade
  tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
  cordon: true
#  drain:
#    force: true
  upgrade:
    image: rancher/k3s-upgrade
  version: "$K3S_VERSION"
---
# Agent plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: agent-plan
  namespace: system-upgrade
  labels:
    k3s-upgrade: agent
spec:
  concurrency: 2
  nodeSelector:
    matchExpressions:
      - {key: k3s-upgrade, operator: Exists}
      - {key: k3s-upgrade, operator: NotIn, values: ["disabled", "false"]}
      # When using k8s version 1.19 or older, swap control-plane with master
      - {key: node-role.kubernetes.io/control-plane, operator: NotIn, values: ["true"]}
  prepare:
    args:
    - prepare
    - server-plan
    image: rancher/k3s-upgrade
  serviceAccountName: system-upgrade
  cordon: true
  drain:
    force: true
  upgrade:
    image: rancher/k3s-upgrade
  version: "$K3S_VERSION"
EOF

kubectl label nodes --all k3s-upgrade=true
