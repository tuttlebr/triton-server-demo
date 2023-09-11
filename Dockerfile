ARG BASE_IMAGE
FROM $BASE_IMAGE
WORKDIR /opt/tritonserver/
COPY model_repository/ model_repository/
