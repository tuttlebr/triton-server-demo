#/bin/bash
seperator=---------------------------------------------------------------
seperator=$seperator$seperator
pattern="%-24s| %-24s| %-8s| %-8s| %-8s| %-8s|\n"
TableWidth=91

MIN_CONCURRENCY=10
MAX_CONCURRENCY=1000
STEP_CONCURRENCY=1
TRITON_POD=$(kubectl -n default get pod -l app=triton-inference-server -o name | grep client | cut -d \/ -f2 | sed -e 's/\\r$//g')
TRAEFIK_ENDPOINT=$(kubectl get svc -l app.kubernetes.io/name=traefik -o=jsonpath='{.items[0].spec.clusterIP}')
MODEL_MANIFEST=$(cat deployed_models.txt)

function traverse_input(){
for row in $(echo $@ | jq -r '.input[] | @base64'); do
    unset ARG
    _jq() {
        echo ${row} | base64 --decode | jq -r ${1} 
    }
    shape=$(_jq '.dims' | jq -r 'join(",")')
    if [[ $shape -ge 0 ]]; then
        ARG=${ARG:+$ARG }" --shape $(_jq '.name'):$shape"
    else
        ARG=${ARG:+$ARG }" --shape $(_jq '.name'):16"
    fi
    echo $ARG
done
}

clear

printf "$pattern" Name Platform Inputs Outputs Batch Status
printf "%.${TableWidth}s\n" "$seperator"
for MODEL in $MODEL_MANIFEST
do
    config=$(kubectl exec $TRITON_POD -- curl -s $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/config)
    name=$(echo "${config}" | jq -r '.name')
    platform=$(echo "${config}" | jq -r '.platform')
    inputs=$(echo "${config}" | jq -r '.input | length')
    outputs=$(echo "${config}" | jq -r '.output | length')
    batchsize=$(echo "${config}" | jq -r '.max_batch_size')

    seq_check=$(echo ${config} | jq '.sequence_batching | length')
    if [[ $seq_check -gt 0 ]]; then
        unset batchsize
        batchsize=1
    elif [[ $batchsize -le 0 ]]; then 
        unset batchsize
        batchsize=1
    fi
    status=$(kubectl exec $TRITON_POD -- curl -m 1 -L -s -o /dev/null -w %{http_code} $TRAEFIK_ENDPOINT:8000/v2/models/$MODEL/versions/1/ready)
    printf "$pattern" $name $platform $inputs $outputs $batchsize $status
    extra_args=$(traverse_input $config)
    kubectl exec $TRITON_POD -- perf_analyzer \
        -m $MODEL \
        -a \
        -i grpc \
        -u $TRAEFIK_ENDPOINT:8001 \
        --percentile=95 \
        --concurrency-range $MIN_CONCURRENCY:$MAX_CONCURRENCY:$STEP_CONCURRENCY \
        -b $batchsize $extra_args > /dev/null 2>&1 &
done
printf "%.${TableWidth}s\n" "$seperator"
