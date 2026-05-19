### Deploy Application and PropagationPolicy

First, let's create a Deployment and a `PropagationPolicy` that specifies application failover settings.
The failover behavior is configured using the `failover.application` field in the `PropagationPolicy`.

1. Create a YAML file with the Deployment and PropagationPolicy.

   <details>
   <summary>nginx-failover.yaml</summary>

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
     propagateDeps: true # application failover is set, propagateDeps must be true
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
   ---
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx
     labels:
       app: nginx
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - image: nginx
           name: nginx
   ```
   </details>

   RUN `cat <<EOF > nginx-failover.yaml
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
   ---
   apiVersion: apps/v1
   kind: Deployment
   metadata:
     name: nginx
     labels:
       app: nginx
   spec:
     replicas: 2
     selector:
       matchLabels:
         app: nginx
     template:
       metadata:
         labels:
           app: nginx
       spec:
         containers:
         - image: nginx
           name: nginx
   EOF`{{exec}}

2. Apply the configuration.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config apply -f nginx-failover.yaml`{{exec}}

3. Check which cluster the application was scheduled to by inspecting the `ResourceBinding`.

   RUN `kubectl --kubeconfig /etc/karmada/karmada-apiserver.config get rb`{{exec}}

   Since the `spreadConstraints` specify `maxGroups: 1` and `minGroups: 1`, Karmada will schedule all replicas to a single cluster. We will assume it was scheduled to `kind-member2` or `kind-member1`. In the next step, we'll verify where it landed and taint that cluster to simulate failure.
