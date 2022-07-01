#!/bin/bash
TRITON_POD=$(kubectl -n default get pod -l app=triton-inference-server -o name | grep client | cut -d \/ -f2 | sed -e 's/\\r$//g')
TRAEFIK_ENDPOINT=$(kubectl get svc -l app.kubernetes.io/name=traefik -o=jsonpath='{.items[0].spec.clusterIP}')
MODEL_MANIFEST=$(cat deployed_models.txt)

clear
echo "*** Triton Server Information ***"
kubectl exec $TRITON_POD -- curl -s $TRAEFIK_ENDPOINT:8000/v2 | jq

result=$(kubectl exec $TRITON_POD -- curl -m 1 -L -s -o /dev/null -w %{http_code} $TRAEFIK_ENDPOINT:8000/v2/health/live)
echo "Live: $result"

result=$(kubectl exec $TRITON_POD -- curl -m 1 -L -s -o /dev/null -w %{http_code} $TRAEFIK_ENDPOINT:8000/v2/health/ready)
echo "Ready: $result"

echo "--------------------------------------------------------------------------------"
for MODEL in $MODEL_MANIFEST
do
    echo "*** $MODEL ***"
    result=$(kubectl exec $TRITON_POD -- curl -m 1 -L -s -o /dev/null -w %{http_code} $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/versions/1/ready)
    echo "Ready: $result"
    echo Writing model configurations to $MODEL'_configurations.json'
    kubectl exec $TRITON_POD -- curl -s $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/config | jq > $MODEL'_configurations.json'
    echo "--------------------------------------------------------------------------------"
done
