### Verify Application failover

After the `tolerationSeconds` (120s) is reached, Karmada will evict the deployment in the failed cluster and re-schedule it to the healthy cluster.

1. Wait for approximately 2 minutes, then check the `ResourceBinding` again.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb`{{exec}}

2. Verify the new cluster assignment and the `gracefulEvictionTasks`.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb nginx-deployment -o yaml | grep -A 10 clusters:`{{exec}}

   You will notice that the application has been re-scheduled to the other member cluster. You will also see a `gracefulEvictionTasks` section indicating that the application was evicted from the previous cluster due to `ApplicationFailure`, with `suppressDeletion: true` (since `purgeMode` is set to `Never`).

3. You can edit `suppressDeletion` to `false` in `gracefulEvictionTasks` to fully evict the application in the failed cluster after you confirm the failure.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config patch rb nginx-deployment --type='json' -p='[{"op": "replace", "path": "/spec/gracefulEvictionTasks/0/suppressDeletion", "value": false}]'`{{exec}}

   After patching, the legacy application in the failed cluster will be purged.
