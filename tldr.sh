#!/bin/bash
clear
bash fetch_models.sh
docker-compose build
docker-compose push
helm upgrade --install triton-demo tritoninferenceserver/ \
    --dependency-update
kubectl -n default get all -l app=triton-inference-server
TRITON_POD=$(kubectl -n default get pod -l app=triton-inference-server -o name | cut -d \/ -f2 | sed -e 's/\\r$//g')
# echo "kubectl logs -f -c triton-inference-server $TRITON_POD"
for MODEL in simple_dyna_sequence simple_sequence simple_string densenet_onnx inception_graphdef simple simple_identity simple_int8 simple_sequence
do
    echo "*** $MODEL ***" 
    DATA_TYPE=$(kubectl exec -c triton-inference-server-dev $TRITON_POD -- curl -s localhost:8000/v2/models/$MODEL/versions/1 | jq -r '.inputs[0].datatype')

    if ! [ $DATA_TYPE == "BYTES" ]; then
        echo "kubectl exec -c triton-inference-server-dev $TRITON_POD -- perf_analyzer -m $MODEL -i grpc -a -u localhost:8001 --percentile=95 --concurrency-range 10:1000"
        kubectl exec -c triton-inference-server-dev $TRITON_POD -- perf_analyzer -m $MODEL -i grpc -a -u localhost:8001 --percentile=95 --concurrency-range 10:1000  > /dev/null 2>&1 &
    else
        INPUT_SHAPE=$(curl -s localhost:8000/v2/models/$MODEL/versions/1 | jq '.inputs[0].shape[1]')
        echo "*** NOT RUNNING PERF ON $MODEL, UNSUPPORTED DATA TYPE $DATA_TYPE ***"
    fi
    echo "--------------------------------------------------------------------------------"
done