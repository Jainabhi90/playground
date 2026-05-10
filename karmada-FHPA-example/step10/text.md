# Trigger Load and Observe Autoscaling

## Check baseline pod distribution

Before generating load, confirm the current pod distribution across clusters:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 get pods`{{exec}}

RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 get pods`{{exec}}

You should see 1 pod total, scheduled to one of the member clusters.

---

## Generate CPU load

Run the following command to generate CPU load on the nginx pod from within the `kind-member1` cluster:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://nginx-service; done"`{{exec}}

This runs a busybox pod inside `kind-member1` that continuously sends HTTP requests to the nginx-service.

> **Note:** Leave this running in the foreground. Open a **new terminal tab** (+) in the Killercoda UI to run the commands below.

---

## Observe scale-up

*(In your new terminal tab)*

After ~15–30 seconds, check the FederatedHPA status:

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

The `REPLICAS` column should have increased above 1 as the FederatedHPA responds to the elevated CPU utilization.

Check the pod distribution across member clusters:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 get pods`{{exec}}

RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 get pods`{{exec}}

You should now see multiple pods spread across both `kind-member1` and `kind-member2`.

---

## Observe scale-down

Go back to your **first terminal tab** and stop the load generator by pressing `Ctrl+C`.

*(Switch back to your new terminal tab)*

Wait ~15–30 seconds for the stabilization window to expire and the CPU average to drop, then check:

RUN `kubectl --kubeconfig=$HOME/.kube/config-member1 get pods`{{exec}}

RUN `kubectl --kubeconfig=$HOME/.kube/config-member2 get pods`{{exec}}

The total replica count should return to 1 as the FederatedHPA scales back down.

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get federatedhpa nginx-fhpa`{{exec}}

`REPLICAS` should show `1` again, confirming the FederatedHPA successfully scaled down the workload across clusters.
