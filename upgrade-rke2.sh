#!/usr/bin/env bash

: "${SUC_VERSION:=0.9.1}"
: "${RKE2_VERSION:=v1.24.1+rke2r2}"

set -o errexit -o nounset -o pipefail

kubectl apply -f "https://github.com/rancher/system-upgrade-controller/releases/download/v${SUC_VERSION}/system-upgrade-controller.yaml"

kubectl apply -f- <<EOF
---
# Server plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: server-plan
  namespace: system-upgrade
  labels:
    rke2-upgrade: server
spec:
  concurrency: 1
  nodeSelector:
    matchExpressions:
       - {key: rke2-upgrade, operator: Exists}
       - {key: rke2-upgrade, operator: NotIn, values: ["disabled", "false"]}
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
    image: rancher/rke2-upgrade
  version: "$RKE2_VERSION"
---
# Agent plan
apiVersion: upgrade.cattle.io/v1
kind: Plan
metadata:
  name: agent-plan
  namespace: system-upgrade
  labels:
    rke2-upgrade: agent
spec:
  concurrency: 2
  nodeSelector:
    matchExpressions:
      - {key: rke2-upgrade, operator: Exists}
      - {key: rke2-upgrade, operator: NotIn, values: ["disabled", "false"]}
      # When using k8s version 1.19 or older, swap control-plane with master
      - {key: node-role.kubernetes.io/control-plane, operator: NotIn, values: ["true"]}
  prepare:
    args:
    - prepare
    - server-plan
    image: rancher/rke2-upgrade
  serviceAccountName: system-upgrade
  cordon: true
  drain:
    force: true
  upgrade:
    image: rancher/rke2-upgrade
  version: "$RKE2_VERSION"
EOF

kubectl label nodes --all rke2-upgrade=true
