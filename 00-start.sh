#!/bin/bash
clear
echo "Uninstalling triton-demo..."
helm uninstall triton-demo --wait 
bash fetch_models.sh
sudo docker compose build
sudo docker compose push

helm install --dependency-update triton-demo tritoninferenceserver/

sleep 10
kubectl -n default get all -l app=triton-inference-server
