# Trigger Load and Observe Autoscaling

## Check baseline pod distribution

Before generating load, confirm the current pod distribution:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

> *Note: As before, you can safely ignore any `metrics.k8s.io` Unhandled Error warnings if they appear.*

You should see 1 pod total.

---

## Generate CPU load

Since the member clusters are running on a different VM in this environment, we will generate load by running a pod directly inside `kind-member1`. To bypass any potential DNS resolution delays, we will target the `ClusterIP` of the service directly!

RUN `SVC_IP=$(kubectl --kubeconfig=$HOME/.kube/config-member1 get svc nginx-service -o jsonpath='{.spec.clusterIP}') && kubectl --kubeconfig=$HOME/.kube/config-member1 run load-generator --image=williamyeh/hey --restart=Never -- -c 1000 -z 1m http://$SVC_IP`{{exec}}

This launches a background pod inside `kind-member1` that continuously sends HTTP requests to the `nginx-service` for exactly 1 minute, and then automatically stops.

---

## Observe scale-up

Wait ~10–25 seconds after starting the load, then check the FederatedHPA status:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

The `REPLICAS` column should have increased above 1.

Check the pod distribution:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

You should now see multiple pods spread across both `kind-member1` and `kind-member2`.

---

## Observe scale-down

Since the `hey` tool automatically stops after 1 minute, you don't need to do anything to stop the load!

Wait about a minute for the load to finish and the stabilization window to expire, then check the pods again:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

The total replica count should return to 1 as the FederatedHPA scales back down.
