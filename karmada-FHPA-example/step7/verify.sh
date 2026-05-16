#!/bin/bash
set -e

kubectl --kubeconfig $HOME/.kube/config -n karmada-system get deployment karmada-metrics-adapter
