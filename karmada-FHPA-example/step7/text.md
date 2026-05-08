# Create PropagationPolicy and Deploy FederatedHPA

## Create PropagationPolicy

**Apply the PropagationPolicy:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/propagationPolicy.yaml`{{exec}}

This policy selects the nginx Deployment and Service, and uses `replicaDivisionPreference: Weighted` (1:1 static weight ratio) to distribute replicas across `kind-member1` and `kind-member2`.

**Verify the policy was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

**Verify pods are running on member clusters:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods`{{exec}}

> **Note:** If no resources appear, wait ~30 seconds and re-run the command. The scheduler needs a moment to propagate and start workloads.

---

## Deploy FederatedHPA

**Apply the FederatedHPA:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/federatedHPA.yaml`{{exec}}

This creates a `FederatedHPA` that monitors the CPU utilization of all nginx pods across both member clusters via the `karmada-metrics-adapter`.
- When average CPU exceeds **10%**, it scales up replicas (up to 10).
- When load drops, it scales back down (to a minimum of 1).
- The stabilization window is configured to 10 seconds so we can observe the scaling actions quickly.

**Verify the FederatedHPA was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

You should see `nginx-fhpa` listed with `MINPODS=1`, `MAXPODS=10`, and `REPLICAS=1`.
