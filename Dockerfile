ARG PYTHON_VERSION=3.12

FROM python:${PYTHON_VERSION}-slim

ARG MLFLOW_VERSION=3.1.1
ARG EXTRA_PIP_PACKAGES=""

ENV MLFLOW_HOME=/opt/mlflow
WORKDIR $MLFLOW_HOME

# Install MLflow with all optional dependencies
RUN pip install --no-cache-dir mlflow[extras]==${MLFLOW_VERSION} ${EXTRA_PIP_PACKAGES}

# Set the entrypoint to run the MLflow Tracking Server and Model Registry
ENTRYPOINT ["mlflow", "server"]
CMD ["--host", "0.0.0.0", "--port", "5000"]