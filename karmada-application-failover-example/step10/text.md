### Verify Application failover

After the `tolerationSeconds` (120s) is reached, Karmada will re-schedule the deployment to the healthy cluster. Because `purgeMode` is set to `Never`, the legacy copy remains until you clear `suppressDeletion`.

1. Wait for approximately 2 minutes, then check the `ResourceBinding` again.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb`{{exec}}

2. Verify the new cluster assignment and the `gracefulEvictionTasks`.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep -A 10 clusters:`{{exec}}

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{range .spec.gracefulEvictionTasks[*]}{.fromCluster}{"\t"}{.suppressDeletion}{"\n"}{end}'`{{exec}}

   You will notice that the application has been re-scheduled to the other member cluster. You will also see a `gracefulEvictionTasks` section indicating the previous cluster failed with `ApplicationFailure`, with `suppressDeletion: true` (since `purgeMode` is set to `Never`).

   > **Note:** If `gracefulEvictionTasks` is empty, wait a bit longer and ensure `health: Unhealthy` appears under `aggregatedStatus`.

3. You can edit `suppressDeletion` to `false` in `gracefulEvictionTasks` to fully evict the application in the failed cluster after you confirm the failure. If multiple tasks are listed, repeat the patch for each index.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config patch rb nginx-deployment --type='json' -p='[{"op": "replace", "path": "/spec/gracefulEvictionTasks/0/suppressDeletion", "value": false}]'`{{exec}}

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config patch rb nginx-deployment --type='json' -p='[{"op": "replace", "path": "/spec/gracefulEvictionTasks/1/suppressDeletion", "value": false}]'`{{exec}}

   After patching, the legacy application in the failed cluster will be purged.

4. Uncordon the node you cordoned in the failed cluster so it can schedule workloads again.

   RUN `FAILED_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.gracefulEvictionTasks[0].fromCluster}')`{{exec}}

   RUN `FAILED_NODE=$(echo $FAILED_CLUSTER | sed 's/kind-//')-control-plane`{{exec}}

   RUN `FAILED_KUBECONFIG=$HOME/.kube/config-$(echo $FAILED_CLUSTER | sed 's/kind-//')`{{exec}}

   RUN `kubectl --kubeconfig $FAILED_KUBECONFIG --context $FAILED_CLUSTER uncordon $FAILED_NODE`{{exec}}
