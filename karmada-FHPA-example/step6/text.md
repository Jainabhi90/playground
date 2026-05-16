### Install metrics-server on member clusters

The FederatedHPA relies on a two-layer metrics pipeline. First, `metrics-server` runs on each member cluster and collects per-pod CPU and memory data.

RUN `bash ~/installMetricsServer.sh`{{exec}}

This script installs `metrics-server` on both `kind-member1` and `kind-member2`. Wait a few moments for the pods to start before proceeding.
