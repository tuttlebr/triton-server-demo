#!/bin/bash
clear
bash fetch_models.sh
docker-compose build
docker-compose push
helm upgrade --install triton-demo tritoninferenceserver/ --dependency-update
kubectl -n default get all -l app=triton-inference-server