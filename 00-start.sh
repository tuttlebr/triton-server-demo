#!/bin/bash


clear
echo "Uninstalling triton-demo..."
helm uninstall triton-demo
bash fetch_models.sh
sudo docker compose build
sudo docker compose push

helm install --dependency-update triton-demo tritoninferenceserver/ \
    --set imageCredentials.password=${NGC_REGISTRY_API_KEY} \
    --set imageCredentials.email=${NGC_REGISTRY_EMAIL}

sleep 10
kubectl -n default get all -l app=triton-inference-server
