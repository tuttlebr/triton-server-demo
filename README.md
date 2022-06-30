# Triton Server Demo

A brief hands on demo of how to use NVIDIA Triton Server for multiple models.

1. Clone me.
2. Initalize env and start services.
   ```bash
   bash 00-start.sh
   ```
   Sample output...
   ```json
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
   --------------------------------------------------------------------------------
   *** densenet_onnx ***
   Ready: 200
   Configuration:
   {
   "name": "densenet_onnx",
   "platform": "onnxruntime_onnx",
   "backend": "onnxruntime",
   "version_policy": {
      "latest": {
         "num_versions": 1
      }
   },
   "max_batch_size": 0,
   "input": [
      {
         "name": "data_0",
         "data_type": "TYPE_FP32",
         "format": "FORMAT_NCHW",
         "dims": [
         3,
         224,
         224
         ],
         "reshape": {
         "shape": [
            1,
            3,
            224,
            224
         ]
         },
         "is_shape_tensor": false,
         "allow_ragged_batch": false,
         "optional": false
      }
   ],
   "output": [
      {
         "name": "fc6_1",
         "data_type": "TYPE_FP32",
         "dims": [
         1000
         ],
         "reshape": {
         "shape": [
            1,
            1000,
            1,
            1
         ]
         },
         "label_filename": "densenet_labels.txt",
         "is_shape_tensor": false
      }
   ],
   "batch_input": [],
   "batch_output": [],
   "optimization": {
      "priority": "PRIORITY_DEFAULT",
      "input_pinned_memory": {
         "enable": true
      },
      "output_pinned_memory": {
         "enable": true
      },
      "gather_kernel_buffer_threshold": 0,
      "eager_batching": false
   },
   "instance_group": [
      {
         "name": "densenet_onnx",
         "kind": "KIND_GPU",
         "count": 1,
         "gpus": [
         0
         ],
         "secondary_devices": [],
         "profile": [],
         "passive": false,
         "host_policy": ""
      }
   ],
   "default_model_filename": "model.onnx",
   "cc_model_filenames": {},
   "metric_tags": {},
   "parameters": {},
   "model_warmup": []
   }
   ...
   ```
3. Launch NVIDIA perf_analyzer
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