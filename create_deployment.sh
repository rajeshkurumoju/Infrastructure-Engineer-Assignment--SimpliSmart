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
