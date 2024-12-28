#!/bin/bash

NAMESPACE="my-namespace"
DEPLOYMENT_NAME="my-deployment"

# Check Deployment status
kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE

# Check Pod status
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME

# Check CPU and Memory usage
kubectl top pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME
