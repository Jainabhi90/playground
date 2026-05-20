### Simulate cluster failure

Now we will construct an abnormal state for the application. We will identify the cluster where the application is currently running, cordon its node (mark it unschedulable), and evict the replicas.

1. Determine the cluster where the application was scheduled.

   RUN `TARGET_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.clusters[0].name}') && if [ -z "$TARGET_CLUSTER" ]; then echo "Error: Failed to determine target cluster"; exit 1; fi`{{exec}}

   RUN `echo "The application is scheduled on: $TARGET_CLUSTER"`{{exec}}

2. Mark the node as unschedulable in the target cluster.
   We construct the node name based on the cluster name (e.g., `kind-member1` has a node named `member1-control-plane`).

   RUN `TARGET_NODE=$(echo $TARGET_CLUSTER | sed 's/kind-//')-control-plane`{{exec}}

   RUN `TARGET_KUBECONFIG=$HOME/.kube/config-$(echo $TARGET_CLUSTER | sed 's/kind-//')`{{exec}}

   RUN `kubectl --kubeconfig $TARGET_KUBECONFIG --context $TARGET_CLUSTER cordon $TARGET_NODE`{{exec}}

   > **Note:** Cordon prevents scheduling on the node. You will uncordon it after failover verification so pods can run again.

3. Delete the pod in the target cluster to construct the abnormal state.

   RUN `kubectl --kubeconfig $TARGET_KUBECONFIG --context $TARGET_CLUSTER delete pod -l app=nginx`{{exec}}

4. Verify that the application is in an `Unhealthy` state.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | sed -n '/aggregatedStatus/,+15p'`{{exec}}

   You will find `health: Unhealthy`. Depending on reporting, `availableReplicas` may be omitted when zero; it is normal to see `unavailableReplicas: 2` instead.
