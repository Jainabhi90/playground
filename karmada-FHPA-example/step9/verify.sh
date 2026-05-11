#!/bin/bash
set -e

kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get serviceexport nginx-service
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get serviceimport nginx-service
