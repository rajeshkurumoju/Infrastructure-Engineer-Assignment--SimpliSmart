## procedure

### Prerequisites

- Access to a Kubernetes cluster.
- `kubectl` installed and configured.
- `Helm` installed.

### Steps

1. **Connect to the Kubernetes Cluster and Install KEDA**

    ```bash
    ./setup_cluster.sh
    ```

2. **Create Deployment**

    ```bash
    ./create_deployment.sh
    ```

3. **Retrieve Health Status**

    ```bash
    ./get_health_status.sh
    ```

## Scripts

### setup_cluster.sh

```bash
#!/bin/bash

# Set KUBECONFIG path if not already set
export KUBECONFIG=/path/to/kubeconfig

# kubectl Installation
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl  -----Make the kubectl binary executable
sudo mv ./kubectl /usr/local/bin/kubectl

# Check kubectl version
kubectl version --client

# eksctl  Installation    
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version


# Install Helm if not already installed
if ! command -v helm &> /dev/null
then
    echo "Helm could not be found. Installing..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm is already installed"
fi

# Add KEDA Helm repo and update
helm repo add kedacore https://kedacore.github.io/charts
helm repo update

# Install KEDA
helm install keda kedacore/keda --namespace keda --create-namespace

# Verify KEDA installation
kubectl get pods -n keda
```

1. **Run the setup_cluster.sh**

    ```bash
    ./setup_cluster.sh
    ```

### create_deployment.sh

```bash
#!/bin/bash

# Define variables
NAMESPACE="my-namespace"
DEPLOYMENT_NAME="my-deployment"
IMAGE="docker pull nginx:latest"
CPU_REQUEST="100m"
CPU_LIMIT="200m"
MEMORY_REQUEST="256Mi"
MEMORY_LIMIT="512Mi"
PORT=80
MIN_REPLICAS=1
MAX_REPLICAS=5
METRIC_NAME="cpu"
TARGET_VALUE="50"

# Create Namespace
kubectl create namespace $NAMESPACE

# Create Deployment
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $DEPLOYMENT_NAME
  template:
    metadata:
      labels:
        app: $DEPLOYMENT_NAME
    spec:
      containers:
      - name: $DEPLOYMENT_NAME
        image: $IMAGE
        ports:
        - containerPort: $PORT
        resources:
          requests:
            memory: $MEMORY_REQUEST
            cpu: $CPU_REQUEST
          limits:
            memory: $MEMORY_LIMIT
            cpu: $CPU_LIMIT
EOF

# Create Service
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ${DEPLOYMENT_NAME}-service
  namespace: $NAMESPACE
spec:
  selector:
    app: $DEPLOYMENT_NAME
  ports:
    - protocol: TCP
      port: 80
      targetPort: $PORT
EOF

# Create HPA (Horizontal Pod Autoscaler) with KEDA
cat <<EOF | kubectl apply -f -
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: ${DEPLOYMENT_NAME}-scaledobject
  namespace: $NAMESPACE
spec:
  scaleTargetRef:
    name: $DEPLOYMENT_NAME
  minReplicaCount: $MIN_REPLICAS
  maxReplicaCount: $MAX_REPLICAS
  triggers:
  - type: $METRIC_NAME
    metadata:
      type: "$METRIC_NAME"
      value: "$TARGET_VALUE"
EOF
```

2. **Run the create_deployment.sh**

    ```bash
    ./create_deployment.sh
    ```
    
### get_health_status.sh

```bash
#!/bin/bash

NAMESPACE="my-namespace"
DEPLOYMENT_NAME="my-deployment"

# Check Deployment status
kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE

# Check Pod status
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME

# Check CPU and Memory usage
kubectl top pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME
```

3. **Run the get_health_status.sh**

 ```bash
 ./get_health_status.sh
 ```
