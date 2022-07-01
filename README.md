# Triton Server Demo

A brief hands on demo of how to use NVIDIA Triton Server for multiple models.

1. Clone me.
2. Initalize env and start services.
   ```bash
   bash 00-start.sh
   ```
3. Check service status

   ```bash
   bash 01-querytriton.sh
   ```

   Sample output...

   ```bash
   *** Triton Server Information ***
   {
   "name": "triton",
   "version": "2.21.0",
   "extensions": [
      "classification",
      "sequence",
      "model_repository",
      "model_repository(unload_dependents)",
      "schedule_policy",
      "model_configuration",
      "system_shared_memory",
      "cuda_shared_memory",
      "binary_tensor_data",
      "statistics",
      "trace"
   ]
   }
   Live: 200
   Ready: 200

   ```

4. Launch NVIDIA perf_analyzer

   ```bash
   bash 02-perfanalyzer.sh
   ```

   Inference tests will run in the background. Sample output:

   ```bash
   Name                    | Platform                | Inputs  | Outputs | Batch   | Status  |
   -------------------------------------------------------------------------------------------
   densenet_onnx           | onnxruntime_onnx        | 1       | 1       | 1       | 200     |
   inception_graphdef      | tensorflow_graphdef     | 1       | 1       | 128     | 200     |
   simple                  | tensorflow_graphdef     | 2       | 2       | 8       | 200     |
   simple_dyna_sequence    | tensorflow_graphdef     | 1       | 1       | 1       | 200     |
   simple_identity         | tensorflow_savedmodel   | 1       | 1       | 8       | 200     |
   simple_int8             | tensorflow_graphdef     | 2       | 2       | 8       | 200     |
   simple_sequence         | tensorflow_graphdef     | 1       | 1       | 1       | 200     |
   -------------------------------------------------------------------------------------------
   ```

5. Monitor using Grafana Dashboard provided

![Grafana Dashboard Sample]("./../Grafana%20Dashboard%20Sample.png?raw=true")
