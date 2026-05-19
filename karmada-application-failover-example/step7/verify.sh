#!/bin/bash
kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep Unhealthy
