#!/bin/bash
MIN_CONCURRENCY=1000
MAX_CONCURRENCY=10000
STEP_CONCURRENCY=100
TRITON_POD=$(kubectl -n default get pod -l app=triton-inference-server -o name | grep client | cut -d \/ -f2 | sed -e 's/\\r$//g')
TRAEFIK_ENDPOINT=$(kubectl get svc -l app.kubernetes.io/name=traefik -o=jsonpath='{.items[0].spec.clusterIP}')

clear

for MODEL in simple_dyna_sequence simple_sequence simple_string densenet_onnx inception_graphdef simple simple_identity simple_int8
do
    DATA_TYPE=$(kubectl exec $TRITON_POD -- curl -s $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/versions/1 | jq -r '.inputs[0].datatype')
    if ! [[ $DATA_TYPE == "BYTES" ]]; then
        echo "*** $MODEL ***" 
        kubectl exec $TRITON_POD -- perf_analyzer -m $MODEL -i grpc -a -u $TRAEFIK_ENDPOINT:8001 --percentile=95 --concurrency-range 100:1000  > /dev/null 2>&1 &
        echo "--------------------------------------------------------------------------------"
    else
        INPUT_SHAPE=$(curl -s $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/versions/1 | jq '.inputs[0].shape[1]')
        echo "*** $MODEL ***"
        echo "Not running, unsupported data type $DATA_TYPE"
        echo "--------------------------------------------------------------------------------"
    fi
done