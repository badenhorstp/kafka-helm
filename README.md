## TODO
* Node and pod affinity to allocate a broker to specific nodes
* Use JMX to check Kafka broker and controller health state
* Side-cart to create NodePorts for connections outside k8s cluster
* 

## Test Kraft
```bash
  . /etc/confluent/docker/bash-config
  /etc/confluent/docker/configure
  /etc/confluent/docker/ensure
  cat /etc/kafka/kafka.properties
  sleep 60m
```
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

## Copilot - Monitor Kafka cluster with JMX
When running Kafka in KRaft mode, which is a mode that does not require ZooKeeper for metadata management, you can check if a Kafka controller is running by looking at the Kafka logs or using Kafka's internal tools to query the status of the cluster.

Here are a few methods to check if a Kafka controller is running in KRaft mode:

1. **Kafka Logs**: Check the Kafka logs for entries that indicate the controller is active. Look for log entries that mention the election of a controller or messages from the controller itself.

2. **JMX Metrics**: Kafka exposes various metrics via JMX that can be monitored. You can use JMX tools to connect to the Kafka process and check the `kafka.controller:type=KafkaController,name=ActiveControllerCount` metric, which should be `1` if a controller is active.

3. **AdminClient API**: If you're using Kafka's AdminClient API, you can query the cluster for its metadata, which includes information about the active controller.

4. **Kafka Command-Line Tools**: Kafka provides command-line tools that can be used to get information about the cluster. For example, you can use `kafka-broker-api-versions.sh` to check if the broker is running, which indirectly indicates if the controller is operational.

Remember, in KRaft mode, Kafka uses an internal Raft consensus protocol to manage metadata, which means that the controllers are responsible for this task instead of ZooKeeper¹²³. If you need more detailed instructions on how to use these methods, please let me know!

Source: Conversation with Bing, 22/05/2024
(1) KRaft - Apache Kafka Without ZooKeeper - Confluent. https://developer.confluent.io/learn/kraft/.
(2) Configure and Monitor KRaft | Confluent Documentation. https://docs.confluent.io/platform/current/kafka-metadata/config-kraft.html.
(3) KRaft Security | Confluent Documentation. https://docs.confluent.io/platform/current/security/kraft-security.html.
(4) KIP-833: Mark KRaft as Production Ready - Apache Kafka - Apache .... https://cwiki.apache.org/confluence/display/KAFKA/KIP-833%3A+Mark+KRaft+as+Production+Ready.
(5) KRaft Overview | Confluent Documentation. https://docs.confluent.io/platform/current/kafka-metadata/kraft.html.

Java Management Extensions (JMX) is a technology that allows you to monitor and manage Java applications, including Kafka, which exposes various metrics and operations through JMX. To use JMX tools for monitoring Kafka, you can follow these general steps:

1. **Enable JMX in Kafka**:
   - Ensure that JMX is enabled on your Kafka brokers. This is usually done by setting environment variables before starting Kafka. For example:
     ```sh
     export JMX_PORT=9999
     export KAFKA_JMX_OPTS="-Dcom.sun.management.jmxremote=true \
     -Dcom.sun.management.jmxremote.authenticate=false \
     -Dcom.sun.management.jmxremote.ssl=false \
     -Djava.rmi.server.hostname=<broker_hostname>"
     ```
   - Replace `<broker_hostname>` with the actual hostname of your Kafka broker.

2. **Connect Using JMX Tools**:
   - Use a JMX client tool like JConsole or VisualVM to connect to the Kafka broker's JMX server. You'll need to specify the JMX port and, if necessary, the hostname.
   - For JConsole, you can start it from the command line by simply typing `jconsole` and then connecting to the Kafka broker using the address `service:jmx:rmi:///jndi/rmi://<broker_hostname>:<JMX_PORT>/jmxrmi`.

3. **Monitor Kafka Metrics**:
   - Once connected, you can browse the MBeans provided by Kafka. Look for beans under the `kafka.server` domain for broker-related metrics or `kafka.controller` for controller metrics.
   - You can view various metrics such as message throughput, broker status, and more.

4. **Set Up Monitoring Dashboards** (Optional):
   - If you want to set up a more permanent monitoring solution, you can integrate JMX with tools like Prometheus, which can scrape JMX metrics and provide a dashboard for monitoring.

Remember to replace `<JMX_PORT>` with the port number you have configured for JMX and `<broker_hostname>` with the actual hostname of your Kafka broker. Also, ensure that your firewall and network settings allow JMX connections to the Kafka brokers¹²³.

If you're running Kafka in a containerized environment or a cloud service, there might be additional steps to expose and secure JMX ports. Always ensure that JMX access is secured, especially if your Kafka cluster is accessible over a public network.

Source: Conversation with Bing, 22/05/2024
(1) Monitoring Kafka with JMX | Confluent Documentation. https://docs.confluent.io/platform/current/kafka/monitoring.html.
(2) How to enable remote JMX on Kafka brokers (for JmxTool)?. https://stackoverflow.com/questions/36708384/how-to-enable-remote-jmx-on-kafka-brokers-for-jmxtool.
(3) How to monitor JMX metrics of Kafka broker on command line?. https://stackoverflow.com/questions/41752581/how-to-monitor-jmx-metrics-of-kafka-broker-on-command-line.
(4) Obtaining a list of available Kafka JMX metrics MBeans for monitoring. http://www.simplekafka.com/monitoring/kafka-obtaining-jmx-mbeans/.
(5) Kafka Monitoring | Basic Concepts and FAQs - Confluent. https://developer.confluent.io/faq/apache-kafka/monitoring-kafka/.

## Copilot - Init Containers
No, an init container cannot directly execute scripts within the primary container. Init containers and primary (or application) containers run in isolation from each other, even though they share the same Pod. The init container runs to completion before the primary container starts, and they do not share processes or file systems².

However, you can use an init container to prepare the environment for the primary container. For example, an init container can place scripts or configuration files into a shared volume that the primary container can access and execute once it starts. Here's a basic example of how you might set this up in a StatefulSet:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: example-statefulset
spec:
  serviceName: "example"
  replicas: 1
  selector:
    matchLabels:
      app: example
  template:
    metadata:
      labels:
        app: example
    spec:
      volumes:
      - name: shared-scripts
        emptyDir: {}
      initContainers:
      - name: init-script-setup
        image: busybox:1.28
        volumeMounts:
        - name: shared-scripts
          mountPath: /scripts
        command: ['sh', '-c', 'echo "echo Hello from the primary container" > /scripts/hello.sh && chmod +x /scripts/hello.sh']
      containers:
      - name: primary-container
        image: my-primary-container-image
        volumeMounts:
        - name: shared-scripts
          mountPath: /scripts
        command: ["/bin/sh", "-c"]
        args: ["/scripts/hello.sh"]
```

In this configuration, the init container creates a script called `hello.sh` in the `shared-scripts` volume. The primary container then executes this script when it starts. Ensure that the script has the correct permissions to be executed by the primary container¹.

Remember to replace `example-statefulset`, `example`, `init-script-setup`, `busybox:1.28`, `my-primary-container-image`, and the script content with the actual names, images, and scripts relevant to your use case.

Source: Conversation with Bing, 22/05/2024
(1) Init Containers | Kubernetes. https://kubernetes.io/docs/concepts/workloads/pods/init-containers/.
(2) Running a shell script to initialize pods in kubernetes (initializing .... https://stackoverflow.com/questions/48403480/running-a-shell-script-to-initialize-pods-in-kubernetes-initializing-my-db-clus.
(3) docker - How to execute python script inside the Kubernetes pod as an .... https://stackoverflow.com/questions/69381983/how-to-execute-python-script-inside-the-kubernetes-pod-as-an-initial-trigger.
(4) How do I run a container from the command line in Kubernetes (like .... https://stackoverflow.com/questions/44712874/how-do-i-run-a-container-from-the-command-line-in-kubernetes-like-docker-run.
(5) How to include script and run it into kubernetes yaml?. https://stackoverflow.com/questions/41674108/how-to-include-script-and-run-it-into-kubernetes-yaml.

## Copilot - RoleBinding and ClsuterRoleBinding
To access the Kubernetes API, a service account needs specific permissions that are granted through roles and role bindings. These permissions are defined using Kubernetes' Role-Based Access Control (RBAC) system. Here's a general outline of the permissions required:

1. **Role**: A Role or ClusterRole contains rules that represent a set of permissions. Permissions are purely additive (there are no "deny" rules).

2. **RoleBinding or ClusterRoleBinding**: A RoleBinding grants the permissions defined in a Role to a user or set of users within a specific namespace. A ClusterRoleBinding grants the permissions defined in a ClusterRole to a user or set of users cluster-wide.

For a service account to access the Kubernetes API, you would typically create a ClusterRole with the necessary API access permissions and then bind that ClusterRole to your service account using a ClusterRoleBinding.

Here's an example of a ClusterRole and ClusterRoleBinding that would allow a service account to list and get pods across the cluster:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-pods
subjects:
- kind: ServiceAccount
  name: <service-account-name>
  namespace: <service-account-namespace>
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Replace `<service-account-name>` and `<service-account-namespace>` with the name and namespace of your service account.

The `verbs` field in the ClusterRole defines what actions the service account can perform. Common verbs include `get`, `list`, `watch`, `create`, `update`, `patch`, and `delete`.

**Note**: Always follow the principle of least privilege by granting only the permissions necessary for the service account to perform its intended tasks¹².

If you need to check what actions a service account can perform, you can use the `kubectl auth can-i` command. For example:

```bash
kubectl auth can-i get pods --as=system:serviceaccount:<namespace>:<service-account-name>
```

This command will tell you if the service account can get pods in the specified namespace.

Source: Conversation with Bing, 22/05/2024
(1) Authorization | Kubernetes. https://kubernetes.io/docs/reference/access-authn-authz/authorization/.
(2) How To Create Kubernetes Service Account For API Access - DevOpsCube. https://devopscube.com/kubernetes-api-access-service-account/.
(3) Using Node Authorization | Kubernetes. https://kubernetes.io/docs/reference/access-authn-authz/node/.
(4) proxy - user permissions needed for token access to kubernetes .... https://stackoverflow.com/questions/47777373/user-permissions-needed-for-token-access-to-kubernetes-dashboard-with-rbac.
(5) Accessing Kubernetes api via Bearer Token Authorization. https://stackoverflow.com/questions/61801522/accessing-kubernetes-api-via-bearer-token-authorization.
