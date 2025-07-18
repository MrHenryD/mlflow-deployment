# mlflow-persistence
MLFlow with persistence enabled.

```
kubectl apply -f pvc.yaml -n mlflow

helm upgrade --install mlflow chart/ \
    --set image.repository=mlflow \
    --set image.tag=3.1.2 \
    --set "persistence.enabled"=true \
    --set "persistence.existingClaim"=mlflow-pvc \
    --namespace mlflow \
    --create-namespace
```