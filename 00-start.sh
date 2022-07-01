#!/bin/bash
clear
helm uninstall triton-demo --wait 
bash fetch_models.sh
docker-compose build
docker-compose push
helm upgrade --install triton-demo tritoninferenceserver/
kubectl -n default get all -l app=triton-inference-server