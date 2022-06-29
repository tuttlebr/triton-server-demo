ARG BASE_IMAGE=nvcr.io/nvidia/tritonserver:22.04-py3
FROM $BASE_IMAGE
WORKDIR /opt/tritonserver/
COPY model_repository/ model_repository/
