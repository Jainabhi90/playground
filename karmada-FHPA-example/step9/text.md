# Configure Multi-Cluster Routing

To allow requests to seamlessly route to our `nginx` pod regardless of which member cluster it is scheduled on, we need to configure Karmada Multi-Cluster Services (MCS).

**1. Apply the ServiceExport and ServiceImport configurations:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/fhpa/serviceExportImport.yaml`{{exec}}

This file does a few things:
- Propagates the `ServiceExport` and `ServiceImport` CRDs to the member clusters.
- Creates a `ServiceExport` object so the `nginx-service` can be discovered across clusters.
- Creates a `ServiceImport` object to expose the `nginx-service` in member clusters.

**2. Verify the Multi-Cluster Service:**

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get svc --operation-scope members`{{exec}}

You should see a new service named `derived-nginx-service` (the imported service) running on the member clusters. This is the service we will use to generate load!
