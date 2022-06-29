#!/bin/bash
set -e

# TensorFlow inception
if ! [[ -f model_repository/inception_graphdef/1/model.graphdef ]]; then
     mkdir -p model_repository/inception_graphdef/1
     wget -O /tmp/inception_v3_2016_08_28_frozen.pb.tar.gz \
          https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz
     (cd /tmp && tar xzf inception_v3_2016_08_28_frozen.pb.tar.gz)
     mv /tmp/inception_v3_2016_08_28_frozen.pb model_repository/inception_graphdef/1/model.graphdef
     chmod 0664 model_repository/inception_graphdef/1/model.graphdef
else
     echo "TensorFlow inception model is already downloaded!"
fi 

# ONNX densenet
if ! [[ -f model_repository/densenet_onnx/1/model.onnx ]]; then
     mkdir -p model_repository/densenet_onnx/1
     wget -O model_repository/densenet_onnx/1/model.onnx \
           https://contentmamluswest001.blob.core.windows.net/content/14b2744cf8d6418c87ffddc3f3127242/9502630827244d60a1214f250e3bbca7/08aed7327d694b8dbaee2c97b8d0fcba/densenet121-1.2.onnx
     chmod 0664 model_repository/densenet_onnx/1/model.onnx
else
     echo "ONNX densenet model is already downloaded!"
fi