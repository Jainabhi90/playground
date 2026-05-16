# Configure Multi-Cluster Routing

To allow requests to seamlessly route to our `nginx` pod regardless of which member cluster it is scheduled on, we need to configure Karmada Multi-Cluster Services (MCS).

**1. Apply the MultiClusterService configuration:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/multiClusterService.yaml`{{exec}}

This file creates a `MultiClusterService` object to enable cross-cluster access for the `nginx-service` across `kind-member1` and `kind-member2`. When a client in one member cluster accesses the service, the request can be routed to backend pods in both clusters.

**2. Verify the Multi-Cluster Service:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

> *Note: If you see `Unhandled Error` warnings regarding metrics, you can safely ignore them.*

You should see the `nginx-service` running on the member clusters. This is the service we will use to generate load!
