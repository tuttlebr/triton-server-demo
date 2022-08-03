# Multi Model NVIDIA Triton Server

## Requirements

- Kubernetes
- NVIDIA GPU Node(s)
- [NVIDIA GPU Operator](https://github.com/NVIDIA/gpu-operator/tree/v1.11.0)
- [Kube Prometheus Stack](https://github.com/prometheus-community/helm-charts/tree/kube-prometheus-stack-34.5.1/charts/kube-prometheus-stack)
- Docker image repo with push/pull authorization
- Docker Compose v3

## Available Models

Deploy up to ten models using Triton Inference Server on Kubernetes load balancing provided by Traefik and horizontal pod autoscaling based on metrics from Triton Metrics Server.

| Name                 | Platform              | Inputs | Outputs | Batch |
| -------------------- | --------------------- | ------ | ------- | ----- |
| densenet-onnx        | onnxruntime_onnx      | 1      | 1       | 1     |
| inception-graphdef   | tensorflow_graphdef   | 1      | 1       | 128   |
| log-parsing-onnx     | onnxruntime_onnx      | 2      | 1       | 32    |
| phishing-bert-onnx   | onnxruntime_onnx      | 2      | 1       | 32    |
| sid-minibert-onnx    | onnxruntime_onnx      | 2      | 1       | 32    |
| simple               | tensorflow_graphdef   | 2      | 2       | 8     |
| simple-dyna-sequence | tensorflow_graphdef   | 1      | 1       | 1     |
| simple-identity      | tensorflow_savedmodel | 1      | 1       | 8     |
| simple-int8          | tensorflow_graphdef   | 2      | 2       | 8     |
| simple-sequence      | tensorflow_graphdef   | 1      | 1       | 1     |

With the exception of `inception-graphdef` and `densenet-onnx`, models are stored using git LFS. To download these you must have git LFS installed.

## Getting Started
1. Clone this repository.

   ```bash
   git clone https://github.com/tuttlebr/triton-server-demo.git
   ```

   ```bash
   cd triton-server-demo
   ```

2. Update the model repo with models stored on git LFS.

   ```bash
   git lfs pull
   ```

3. Build the required Docker images and download the `inception-graphdef` and `densenet-onnx` models. This will also attempt to push the containers to a repository accessible by your Kubernetes nodes and should be updated as needed. This will also deploy the Helm chart. 

   ```bash
   bash 00-start.sh
   ```

4. This will query the Triton Server. It may take a while for all pods to come online and for Triton to start all models. You can use this to check the status. 
   ```bash
   bash 01-querytriton.sh
   ```

5. Run the NVIDIA `perf_analyzer` from within a Triton Client pod. 
   ```bash
   bash 02-perfanalyzer.sh
   ```
6. You can monitor the Triton Server by uploading the `triton-server-dashboard.json` file to your Grafana dashboard. 
   ![Grafana Dashboard Sample]("./../Grafana%20Dashboard%20Sample.png?raw=true")
