ARG BASE_IMAGE=nvcr.io/nvidia/tritonserver:22.04-py3
FROM $BASE_IMAGE
COPY fetch_models.sh .
RUN bash fetch_models.sh
ADD model_repository/ model_repository
ADD client /workspace
RUN pip3 install jupyter jupyterlab tritonclient[all] pillow attrdict