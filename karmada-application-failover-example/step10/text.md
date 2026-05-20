### Verify Application failover

After the `tolerationSeconds` (120s) is reached, Karmada will re-schedule the deployment to the healthy cluster.

1. Wait for failover to complete (automated polling)

   First, export TARGET_CLUSTER from the previous step:

   RUN `export TARGET_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.clusters[0].name}')`{{exec}}

   Instead of guessing, poll until failover is detected:

   RUN `for i in {1..30}; do CLUSTERS=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.clusters[*].name}'); if [[ "$CLUSTERS" != *"$TARGET_CLUSTER"* ]]; then echo "✓ Failover complete! Application now on: $CLUSTERS"; break; fi; echo "Waiting for failover... ($i/30, ~$(($i * 10))s elapsed)"; sleep 10; done`{{exec}}

2. Verify the new cluster assignment and the `gracefulEvictionTasks`.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep -A 10 clusters:`{{exec}}

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{range .spec.gracefulEvictionTasks[*]}{.fromCluster}{"\t"}{.suppressDeletion}{"\n"}{end}'`{{exec}}

   You will notice that the application has been re-scheduled to the other member cluster. You will also see a `gracefulEvictionTasks` section indicating the previous cluster failed with `ApplicationFailure`, with `suppressDeletion: true` (since `purgeMode` is set to `Never`).

   > **Note:** If `gracefulEvictionTasks` is empty, wait a bit longer and ensure `health: Unhealthy` appears under `aggregatedStatus`.

3. Set `suppressDeletion` to `false` for all gracefulEvictionTasks to fully evict the application in the failed cluster.

   RUN `TASK_COUNT=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.gracefulEvictionTasks | length}'); for i in $(seq 0 $((TASK_COUNT - 1))); do kubectl --kubeconfig /etc/karmada/karmada-apiserver.config patch rb nginx-deployment --type='json' -p="[{\"op\": \"replace\", \"path\": \"/spec/gracefulEvictionTasks/$i/suppressDeletion\", \"value\": false}]"; done`{{exec}}

   After patching, the legacy application in the failed cluster will be purged.

4. Uncordon the node you cordoned in the failed cluster so it can schedule workloads again.

   RUN `FAILED_CLUSTER=$(kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o jsonpath='{.spec.gracefulEvictionTasks[0].fromCluster}')`{{exec}}

   RUN `FAILED_NODE=$(echo $FAILED_CLUSTER | sed 's/kind-//')-control-plane`{{exec}}

   RUN `FAILED_KUBECONFIG=$HOME/.kube/config-$(echo $FAILED_CLUSTER | sed 's/kind-//')`{{exec}}

   RUN `kubectl --kubeconfig $FAILED_KUBECONFIG --context $FAILED_CLUSTER uncordon $FAILED_NODE`{{exec}}

