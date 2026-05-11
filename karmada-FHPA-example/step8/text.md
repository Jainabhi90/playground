# Create PropagationPolicy

**Apply the PropagationPolicy:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/propagationPolicy.yaml`{{exec}}

This policy selects the nginx Deployment and Service, and uses `replicaDivisionPreference: Weighted` (1:1 static weight ratio) to distribute replicas across `kind-member1` and `kind-member2`.

**Verify the policy was created:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

**Verify pods are running on member clusters:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

> **Note:** It takes a moment for the scheduler to propagate the workload and for the clusters to download the image. If you see "No resources found", wait ~30 seconds and re-run the command. You should see 1 pod running on one of the member clusters (since replicas is 1).
> 
> *Troubleshooting:* If you see several lines of `Unhandled Error` regarding `metrics.k8s.io`, this is completely normal! It just means the Karmada metrics adapter is still starting up in the background. You can safely ignore these warnings as long as the pod is listed at the bottom.
