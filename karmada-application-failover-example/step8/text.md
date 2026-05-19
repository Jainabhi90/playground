# Create PropagationPolicy for Application Failover

**Create PropagationPolicy for `nginx` with application failover:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f ~/nginx/propagationPolicy.yaml`{{exec}}

This applies a policy that enables application-level failover.
<details>
<summary>propagationPolicy.yaml</summary>

```yaml
apiVersion: policy.karmada.io/v1alpha1
kind: PropagationPolicy
metadata:
  name: nginx-propagation
spec:
  failover:
    application:
      decisionConditions:
        tolerationSeconds: 120
      purgeMode: Never
  propagateDeps: true
  resourceSelectors:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
  placement:
    clusterAffinity:
      clusterNames:
        - kind-member1
        - kind-member2
    spreadConstraints:
      - maxGroups: 1
        minGroups: 1
        spreadByField: cluster
```

</details>

This policy selects the nginx Deployment and configures it so that if the application fails and is unhealthy for 120 seconds (`tolerationSeconds: 120`), it will be evicted and re-scheduled to another cluster.

**Verify policy exists:**

RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get propagationpolicy nginx-propagation`{{exec}}

This checks that the propagation policy has been successfully created.
