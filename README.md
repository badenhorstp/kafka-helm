## Configure new Kafka cluster
Generate new cluster ID
```zsh
kafka-storage.sh random-uuid

```
## Copilot - PodAffinity
To ensure that each Pod in a StatefulSet is always scheduled to be allocated to the same node in sequence, you can use a combination of `nodeAffinity` and `podAffinity` along with labels on the nodes. Here's an example StatefulSet manifest that demonstrates this approach:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: example-statefulset
spec:
  serviceName: "example-service"
  replicas: 3
  selector:
    matchLabels:
      app: example-app
  template:
    metadata:
      labels:
        app: example-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: node
                operator: In
                values:
                - "node01"
                - "node02"
                - "node03"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            labelSelector:
              matchLabels:
                app: example-app
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: example-container
        image: example-image
```

In this configuration:
- The `nodeAffinity` is used to specify a list of nodes where the Pods can be scheduled.
- The `podAffinity` with `topologyKey: "kubernetes.io/hostname"` ensures that Pods with the same label are scheduled on the same node.

To ensure that each Pod is allocated to a specific node, you would label each node with a unique label and then use `nodeAffinity` to match those labels. For example, you could label your nodes like this:

```bash
kubectl label nodes node01 example-app=myapp-0
kubectl label nodes node02 example-app=myapp-1
kubectl label nodes node03 example-app=myapp-2
```

Then, modify the StatefulSet manifest to match these labels:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: example-statefulset
spec:
  serviceName: "example-service"
  replicas: 3
  selector:
    matchLabels:
      app: example-app
  template:
    metadata:
      labels:
        app: example-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: "example-app"
                operator: In
                values:
                - "myapp-0"
                - "myapp-1"
                - "myapp-2"
      containers:
      - name: example-container
        image: example-image
```

This setup will ensure that `myapp-0` is always scheduled on `node01`, `myapp-1` on `node02`, and `myapp-2` on `node03`. Keep in mind that this approach can lead to scheduling issues if the specified nodes are not available or do not have sufficient resources¹.

Source: Conversation with Bing, 16/05/2024
(1) Is it possible to assign a pod of StatefulSet to a specific node of a .... https://stackoverflow.com/questions/60242339/is-it-possible-to-assign-a-pod-of-statefulset-to-a-specific-node-of-a-kubernetes.
(2) Schedule few statefulset pods on one node and rest on other node in a .... https://stackoverflow.com/questions/64279594/schedule-few-statefulset-pods-on-one-node-and-rest-on-other-node-in-a-kubernetes.
(3) How can we assign one of the pod's of StatefulSet to a specific node of .... https://stackoverflow.com/questions/66583673/how-can-we-assign-one-of-the-pods-of-statefulset-to-a-specific-node-of-a-kubern.
(4) How to schedule a pod deployed by a statefulset to a specific node .... https://access.redhat.com/solutions/6979893.
(5) What is the correct way to use specific node for each statefulset pods?. https://stackoverflow.com/questions/69336104/what-is-the-correct-way-to-use-specific-node-for-each-statefulset-pods.

## Copilot - Enable Feature Gate
To enable feature gates on Minikube, you can use the `--feature-gates` flag when starting your Minikube cluster. This flag allows you to turn on or off specific Kubernetes features. Here's how you can use it:

```bash
minikube start --feature-gates=FeatureName=true
```

Replace `FeatureName` with the name of the Kubernetes feature you want to enable. If you want to enable multiple feature gates, separate them with commas:

```bash
minikube start --feature-gates=FeatureName1=true,FeatureName2=false
```

This command will start Minikube with the specified feature gates enabled or disabled according to the values you set¹.

Remember to check the Kubernetes documentation or Minikube's help command to ensure that the feature gates you want to enable are supported and to understand their current stage (Alpha, Beta, or GA) and impact².

Source: Conversation with Bing, 17/05/2024
(1) Configuration | minikube. https://minikube.sigs.k8s.io/docs/handbook/config/.
(2) Feature Gates | Kubernetes. https://kubernetes.io/docs/reference/command-line-tools-reference/feature-gates/.
(3) Feature Gates — How to enable Kubernetes Alpha features. https://faun.pub/feature-gates-how-to-enable-kubernetes-alpha-features-fdb38dc3a9aa.
(4) undefined. https://kubernetes.io/docs/setup/production-environment/container-runtimes/.
