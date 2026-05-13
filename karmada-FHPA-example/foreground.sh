#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# variable define
kind_version=v0.17.0
host_cluster_ip=172.30.1.2 #host node where Karmada is located
member_cluster_ip=172.30.2.2
local_ip=127.0.0.1
KUBECONFIG_PATH=${KUBECONFIG_PATH:-"${HOME}/.kube"}

function installKind() {
    cat << EOF > installKind.sh
    wget https://github.com/kubernetes-sigs/kind/releases/download/${kind_version}/kind-linux-amd64
    chmod +x kind-linux-amd64
    sudo mv kind-linux-amd64 /usr/local/bin/kind
EOF
}

function createCluster() {
    cat << EOF > createCluster.sh
    kind create cluster --name=member1 --config=cluster1.yaml
    mv $HOME/.kube/config ~/config-member1
    kind create cluster --name=member2 --config=cluster2.yaml
    mv $HOME/.kube/config config-member2
    KUBECONFIG=~/config-member1:~/config-member2 kubectl config view --merge --flatten >> ${KUBECONFIG_PATH}/config
    # modify ip
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member1
    # set StrictHostKeyChecking to no to avoid prompting, the same below
    scp -o StrictHostKeyChecking=no config-member1 root@${host_cluster_ip}:$HOME/.kube/config-member1
    sed -i "s/${local_ip}/${member_cluster_ip}/g"  config-member2
    scp -o StrictHostKeyChecking=no config-member2 root@${host_cluster_ip}:$HOME/.kube/config-member2
EOF
}

function cluster1Config() {
    cat << EOF > cluster1.yaml
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6443
EOF
}

function cluster2Config() {
    cat << EOF > cluster2.yaml 
    kind: Cluster
    apiVersion: kind.x-k8s.io/v1alpha4
    networking:
      apiServerAddress: "${member_cluster_ip}"
      apiServerPort: 6444
EOF
}

function installMetrics() {
    cat << 'EOF' > installMetrics.sh
kubectl --kubeconfig=$HOME/.kube/config-member1 apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl --kubeconfig=$HOME/.kube/config-member1 patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

kubectl --kubeconfig=$HOME/.kube/config-member2 apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl --kubeconfig=$HOME/.kube/config-member2 patch deployment metrics-server -n kube-system --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
EOF
    chmod +x installMetrics.sh
}

function nginxDeployment() {
    cat << EOF > nginxDeployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
        resources:
          requests:
            cpu: 25m
            memory: 64Mi
          limits:
            cpu: 25m
            memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
EOF
}

function propagationPolicy() {
    cat << EOF > propagationPolicy.yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
    - apiVersion: v1
      kind: Service
      name: nginx-service
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    replicaScheduling:
      replicaDivisionPreference: Weighted
      replicaSchedulingType: Divided
      weightPreference:
        staticWeightList:
          - targetCluster:
              clusterNames:
                - kind-member1
            weight: 1
          - targetCluster:
              clusterNames:
                - kind-member2
            weight: 1
EOF
}

function federatedHPA() {
    cat << EOF > federatedHPA.yaml
apiVersion: autoscaling.karmada.io/v1alpha1
kind: FederatedHPA
metadata:
  name: nginx-fhpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 1
  maxReplicas: 10
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 10
    scaleUp:
      stabilizationWindowSeconds: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 10
EOF
}

function multiClusterService() {
    cat << EOF > multiClusterService.yaml
apiVersion: networking.karmada.io/v1alpha1
kind: MultiClusterService
metadata:
  name: nginx-service
spec:
  types:
    - CrossCluster
  consumerClusters:
    - name: kind-member1
    - name: kind-member2
  providerClusters:
    - name: kind-member1
    - name: kind-member2
EOF
}

function copyConfigFilesToNode() {
    scp -o StrictHostKeyChecking=no \
        installKind.sh \
        createCluster.sh \
        cluster1.yaml \
        cluster2.yaml \
        root@${member_cluster_ip}:~
}

kubectl delete node node01
kubectl taint node controlplane node-role.kubernetes.io/control-plane:NoSchedule-

# prepare helper scripts and cluster config files
installKind
createCluster
cluster1Config
cluster2Config
copyConfigFilesToNode

installMetrics

# generate nginx and FHPA config files
mkdir -p ~/fhpa
cd ~/fhpa
nginxDeployment
propagationPolicy
federatedHPA
multiClusterService
cd ~

# clean screen 
clear
