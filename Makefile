IMAGE_NAME ?= mlflow
RELEASE_NAME ?= mlflow
MLFLOW_VERSION ?= 3.1.2

# .PHONY: tells Make that these targets are not actual files
PHONY: all

update-namespace:
	@echo "Updating namespace to $(NAMESPACE)..."
	@kubectl config set-context --current --namespace=$(NAMESPACE)
	@echo "Namespace updated to $(NAMESPACE)."

build-image:
	@echo "Building Docker image..."
	@docker build -t $(IMAGE_NAME):$(MLFLOW_VERSION) --build-arg MLFLOW_VERSION=$(MLFLOW_VERSION) .

kind-import:
	@echo "Importing Docker image into kind cluster..."
	@kind load docker-image $(IMAGE_NAME):$(MLFLOW_VERSION) --name kind
	@echo "Docker image $(IMAGE_NAME):$(MLFLOW_VERSION) imported into kind cluster."

kind-context:
	@echo "Setting kubectl context to kind cluster..."
	@kubectl config use-context kind-kind
	@echo "Current context set to: $(shell kubectl config current-context)"

clean:
	@echo "Cleaning up kind cluster..."
	@kind delete cluster --name kind

run-compose:
	@docker-compose down --remove-orphans
	@echo "Running docker-compose..."
	@docker-compose up --build

helm-check:
	@echo "Checking Helm chart..."
	@helm lint chart/
	@echo "Helm chart is valid."

helm-render:
	@echo "Rendering Helm chart templates..."
	@helm template $(RELEASE_NAME) chart/ \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(MLFLOW_VERSION)

helm-upgrade:
	@echo "Installing Helm chart..."
	@helm upgrade --install $(RELEASE_NAME) chart/ \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(MLFLOW_VERSION) \
		--namespace mlflow \
		--create-namespace
	@echo "Helm release mlflow upgraded or installed successfully."

helm-uninstall:
	@echo "Uninstalling Helm release..."
	@helm uninstall $(RELEASE_NAME) --namespace $(NAMESPACE)
	@echo "Helm release $(RELEASE_NAME) uninstalled successfully."
