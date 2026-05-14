### Install metrics-server and karmada-metrics-adapter

The FederatedHPA relies on a two-layer metrics pipeline:
- **`metrics-server`** runs on each member cluster and collects per-pod CPU/memory data.
- **`karmada-metrics-adapter`** runs on the Karmada control plane and aggregates those metrics so the FederatedHPA controller can read them.

RUN `bash ~/installMetrics.sh`{{exec}}

This script installs `metrics-server` on both `kind-member1` and `kind-member2`, and then enables the `karmada-metrics-adapter` addon on the Karmada control plane. Wait a few moments for the pods to start before proceeding.
