# Create PropagationPolicy

**Apply the PropagationPolicy:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/propagationPolicy.yaml`{{exec}}

This policy selects the nginx Deployment and Service, and uses `replicaDivisionPreference: Weighted` (1:1 static weight ratio) to distribute replicas across `kind-member1` and `kind-member2`.

**Verify the policy was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

**Verify pods are running on member clusters:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods`{{exec}}

> **Note:** If no resources appear, wait ~30 seconds and re-run the command. The scheduler needs a moment to propagate and start workloads.
