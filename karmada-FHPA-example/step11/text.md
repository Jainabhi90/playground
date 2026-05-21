# Deploy FederatedHPA

**Apply the FederatedHPA:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/federatedHPA.yaml`{{exec}}

This creates a `FederatedHPA` that monitors the CPU utilization of all nginx pods across both member clusters via the `karmada-metrics-adapter`.

- When average CPU exceeds **10%**, it scales up replicas (up to 4).
- When load drops, it scales back down (to a minimum of 1).
- The stabilization window is configured to 10 seconds so we can observe the scaling actions quickly.

**Verify the FederatedHPA was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

You should see `nginx-fhpa` listed with `MINPODS=1`, `MAXPODS=4`, and `REPLICAS=1`.
