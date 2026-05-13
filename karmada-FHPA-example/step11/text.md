# Trigger Load and Observe Autoscaling

## Check baseline pod distribution

Before generating load, confirm the current pod distribution:

RUN `karmadactl --kubeconfig /etc/karmada/karmada-apiserver.config get pods --operation-scope members`{{exec}}

> *Note: As before, you can safely ignore any `metrics.k8s.io` Unhandled Error warnings if they appear.*

You should see 1 pod total.

---

## Install load testing tool

We will use the `hey` tool to send requests to our multi-cluster service. Let's install it on `member1`:

RUN `wget -O hey https://storage.googleapis.com/hey-releases/hey_linux_amd64 && chmod +x hey && docker cp hey member1-control-plane:/usr/local/bin/hey`{{exec}}

---

## Generate CPU load

We need to hit the exact ClusterIP of our `nginx-service`. Let's fetch the IP and start the load generation!

RUN `SVC_IP=$(kubectl --kubeconfig=$HOME/.kube/config-member1 get svc nginx-service -o jsonpath='{.spec.clusterIP}') && docker exec member1-control-plane hey -c 1000 -z 1m http://$SVC_IP`{{exec}}

This continuously sends HTTP requests to the `nginx-service` for exactly 1 minute, and then automatically stops.

---

## Observe scale-up

Wait ~15–30 seconds after starting the load, then check the FederatedHPA status:

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
