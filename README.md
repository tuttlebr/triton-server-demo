# Triton Server Demo

A brief hands on demo of how to use NVIDIA Triton Server for multiple models.

1. Clone me.
2. Download a couple pre-trained models
   ```bash
   bash fetch_models.sh
   ```
3. Build Docker Image
   ```bash
   docker-compose build
   ```
4. Push Docker Images to a repo available by all nodes in Cluster.
   ```bash
   docker-compose push
   ```
5. Install the demo using Helm

   ```bash
   helm install triton-demo tritoninferenceserver
   ```

   Sample Output:

   ```bash
    NAME: tritondemo
    LAST DEPLOYED: Mon Jun 13 17:36:28 2022
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    tritoninferenceserver Installation Complete!

    Monitor All Objects:
        kubectl -n default get all -o wide -l app=tritoninferenceserver

    Follow Triton Server Logs:
        triton_pod=$(kubectl -n default get pod -l app=tritoninferenceserver -o name | cut -d \/ -f2 | sed -e 's/\\r$//g')
        kubectl -n default logs -f $triton_pod -c tritoninferenceserver

    Jupyter Lab URL:
        master_ip=$(kubectl get nodes -l node-role.kubernetes.io/master= --no-headers -o custom-columns=IP:.status.addresses.*.address | cut -f1 -d, | head -1)
        nodePort="$(kubectl get svc -n default tritondemo-tritoninferenceserver --no-headers -o custom-columns=PORT:.spec.ports[?\(@.name==\"http2\"\)].nodePort)"
        jl_url="http://${master_ip}:${nodePort}"
   ```

6. Review deployed services:

   ```bash
   kubectl -n default get all -o wide -l app=tritoninferenceserver
   ```

   Sample Output:

   ```bash
    NAME                                                    READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
    pod/tritondemo-tritoninferenceserver-5f66ccb7b5-htrjk   2/2     Running   0          38s   10.1.2.3        dgx-01       <none>           <none>

    NAME                                       TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                                                       AGE   SELECTOR
    service/tritondemo-tritoninferenceserver   NodePort   10.2.3.4       <none>        8000:30800/TCP,8001:30801/TCP,8002:30802/TCP,8888:30888/TCP   38s   app=tritoninferenceserver,release=tritondemo

    NAME                                               READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS                                               IMAGES                                                                                        SELECTOR
    deployment.apps/tritondemo-tritoninferenceserver   1/1     1            1           38s   tritoninferenceserver,tritoninferenceserver-jupyterlab   registry.local:31500/triton-server-demo:0.1.0,registry.local:31500/triton-server-demo:0.1.0   app=tritoninferenceserver,release=tritondemo

    NAME                                                          DESIRED   CURRENT   READY   AGE   CONTAINERS                                               IMAGES                                                                                        SELECTOR
    replicaset.apps/tritondemo-tritoninferenceserver-5f66ccb7b5   1         1         1       38s   tritoninferenceserver,tritoninferenceserver-jupyterlab   registry.local:31500/triton-server-demo:0.1.0,registry.local:31500/triton-server-demo:0.1.0   app=tritoninferenceserver,pod-template-hash=5f66ccb7b5,release=tritondemo
   ```

7. Review theJupyter Lab environment:

   1. Jupyter Lab: `dgx-01:30888`
   2. Triton HTTP: `dgx-01:30800`
   3. Triton gRPC: `dgx-01:30801`
   4. Triton Metrics: `dgx-01:30802`

8. Monitor Triton Server Logs:

   1. `kubectl logs -f pod/tritondemo-tritoninferenceserver-5f66ccb7b5-htrjk -c tritoninferenceserver`

9. Uninstall
   ```bash
   helm uninstall triton-demo
   ```

### TensorRT Model Prep
```bash
docker run -it --rm \
   -p 8888:8888 \
   --ulimit memlock=-1 \
   --ulimit stack=67108864 \
   --runtime nvidia \
   -v $PWD:/workspace/local \
   --entrypoint=jupyter \
   registry.local:31500/triton-server-demo:0.1.0 \
   lab --ip=0.0.0.0 \
   --no-browser \
   --allow-root \
   --port=8888 \
   --NotebookApp.token='' \
   --NotebookApp.password='' \
   --NotebookApp.allow_origin='*' \
   --NotebookApp.base_url=/ \
   --NotebookApp.notebook_dir=/workspace
```
