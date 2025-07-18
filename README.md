# mlflow-deployment

A comprehensive repository for deploying [MLflow](https://mlflow.org/) using Docker Compose and Helm on Kubernetes, with support for persistent storage and external databases.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Directory Structure](#directory-structure)
- [Quickstart](#quickstart)
  - [Docker Compose](#docker-compose)
  - [Kubernetes with Helm](#kubernetes-with-helm)
- [Persistence](#persistence)
- [External Database](#external-database)
- [Development](#development)
- [Makefile Commands](#makefile-commands)
- [Troubleshooting](#troubleshooting)
- [References](#references)

---

## Overview

This project provides a production-ready setup for running MLflow, including:

- Docker Compose for local development and testing.
- Helm chart for Kubernetes deployments.
- Persistent storage configuration.
- Integration with PostgreSQL as the backend store.

---

## Features

- **MLflow Tracking Server** with artifact and backend store support.
- **Docker Compose** for easy local setup.
- **Helm Chart** for scalable Kubernetes deployments.
- **PersistentVolume** and **PersistentVolumeClaim** examples.
- **External Database** configuration (PostgreSQL).
- **Customizable** via environment variables and Helm values.

---

## Directory Structure

```
mlflow-deployment/
├── chart/                   # Helm chart for Kubernetes deployment
│   ├── templates/
│   ├── values.yaml
│   └── ...
├── docker-compose.yml       # Docker Compose setup for local use
├── Dockerfile               # MLflow Docker image
├── Makefile                 # Automation commands
├── examples/
│   ├── mlflow-persistence/  # PV/PVC examples for persistence
│   └── mlflow-external-db/  # External DB examples
└── README.md
```

---

## Quickstart

### Docker Compose

1. **Build and run MLflow locally:**
    ```sh
    make run-compose
    ```
2. **Access MLflow UI:**  
   Visit [http://localhost:5003](http://localhost:5003)

### Kubernetes with Helm

1. **Create a namespace (optional):**
    ```sh
    kubectl create namespace mlflow
    ```

2. **(Optional) Apply PersistentVolume and PersistentVolumeClaim:**
    ```sh
    kubectl apply -f examples/mlflow-persistence/pvc.yaml -n mlflow
    ```

3. **Install or upgrade MLflow with Helm:**
    ```sh
    helm upgrade --install mlflow chart/ \
      --set image.repository=mlflow \
      --set image.tag=3.1.2 \
      --set persistence.enabled=true \
      --set persistence.existingClaim=mlflow-pvc \
      --namespace mlflow \
      --create-namespace
    ```

4. **Port-forward to access the UI:**
    ```sh
    kubectl port-forward svc/mlflow-mlflow 5003:5000 -n mlflow
    ```
    Then open [http://localhost:5003](http://localhost:5003)

---

## Persistence

- Persistent storage is enabled via Kubernetes PVCs.
- See [`examples/mlflow-persistence/pvc.yaml`](examples/mlflow-persistence/pvc.yaml) for a sample PV/PVC.
- Configure persistence in `values.yaml` or via `--set` flags:
    ```yaml
    persistence:
      enabled: true
      existingClaim: mlflow-pvc
      size: 10Gi
      storageClass: standard
    ```

---

## External Database

- MLflow uses PostgreSQL as the backend store.
- The connection string is set in the Docker Compose and Helm values.
- Example for Docker Compose:
    ```yaml
    --backend-store-uri postgresql+psycopg2://admin:password@postgres/mlflow
    ```
- For Kubernetes, set the backend store URI via environment variables or Helm values.

---

## Development

- **Build Docker image:**
    ```sh
    make build-image
    ```
- **Import image into kind cluster:**
    ```sh
    make kind-import
    ```
- **Render Helm templates:**
    ```sh
    make helm-render
    ```

---

## Makefile Commands

| Command           | Description                                 |
|-------------------|---------------------------------------------|
| `make run-compose`| Run MLflow with Docker Compose              |
| `make build-image`| Build the MLflow Docker image               |
| `make kind-import`| Import image into kind cluster              |
| `make helm-check` | Lint the Helm chart                         |
| `make helm-render`| Render Helm templates to stdout             |
| `make helm-upgrade`| Install/upgrade MLflow via Helm            |
| `make clean`      | Delete kind cluster                         |

---

## Troubleshooting

- **PVC unbound:**  
  Ensure your PersistentVolume and PersistentVolumeClaim match in size, access mode, and storage class.
- **Pod not starting:**  
  Check logs with `kubectl logs <pod> -n mlflow` and describe resources with `kubectl describe pod <pod> -n mlflow`.
- **Database connection issues:**  
  Verify the backend store URI and database service availability.

---

## References

- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
- [Docker Compose](https://docs.docker.com/compose/)