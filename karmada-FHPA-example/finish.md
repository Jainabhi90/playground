# Summary

In this scenario, we learned how to:

- Set up the Karmada control plane using `karmadactl init`
- Create two Kind-based member clusters and join them to Karmada
- Install the `metrics-server` on member clusters (required for CPU-based scaling)
- Deploy a multi-replica nginx workload with CPU resource limits
- Apply a **PropagationPolicy** to distribute the workload across both member clusters
- Create a **FederatedHPA** resource that monitors CPU utilization across all member clusters and automatically scales replicas
- Generate CPU load using a busybox pod and observe the FederatedHPA trigger a scale-up
- Stop the load and observe FederatedHPA scale the workload back down
