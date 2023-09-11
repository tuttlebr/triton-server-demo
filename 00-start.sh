#!/bin/bash

clear
echo "Uninstalling triton-demo..."
helm uninstall triton-demo
bash fetch_models.sh
# docker compose build
# docker compose push

helm install --dependency-update triton-demo tritoninferenceserver/ \
    --set imageCredentials.password=${NGC_REGISTRY_API_KEY} \
    --set imageCredentials.email=${NGC_REGISTRY_EMAIL}

sleep 10

TRITON_POD=$(kubectl -n default get pod -l app=triton-inference-server -o name | grep client | cut -d \/ -f2 | sed -e 's/\\r$//g')
echo "Copying models from host to PVC..."
sleep 10
kubectl cp model_repository ${TRITON_POD}:/opt/tritonserver/
kubectl -n default get all -l app=triton-inference-server
