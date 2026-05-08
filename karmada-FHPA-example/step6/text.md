# Deploy nginx Workload

**Apply the nginx Deployment and Service:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/nginxDeployment.yaml`{{exec}}

This creates the nginx workload (1 replica) and a ClusterIP Service in the Karmada control plane.

> **Crucial Detail for Autoscaling:** The Deployment includes explicit CPU `requests` and `limits`. CPU-based autoscaling will not work without these resource boundaries defined on the containers.

**Verify the Deployment exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get deployment nginx`{{exec}}

This confirms the nginx Deployment has been created in the Karmada control plane.

**Verify the Service exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get service nginx-service`{{exec}}

This confirms the nginx-service has been created.

> **Note:** At this point the workload exists only on the Karmada control plane. It will be propagated to member clusters in the next step.
