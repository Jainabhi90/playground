#!/bin/bash
set -e

karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa
