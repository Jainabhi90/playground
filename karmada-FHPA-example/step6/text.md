### Install metrics-server on member clusters

**Note:** The FederatedHPA relies on metrics collected from member clusters. The `metrics-server` is required on all member clusters to provide CPU utilization data.

RUN `bash ~/installMetrics.sh`{{exec}}

This script installs the `metrics-server` on both `kind-member1` and `kind-member2`. Wait a few moments for the pods to start.
