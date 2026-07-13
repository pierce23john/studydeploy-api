# StudyDeployApi

Minimal ASP.NET Core .NET 10 API for comparing Azure Container Apps and Azure Kubernetes Service deployment flows.

## Layout

- `src/StudyDeployApi/`: application source
- `Dockerfile`: API container build
- `deploy/aca/api.containerapp.yaml`: Azure Container Apps manifest
- `deploy/aks/`: Kubernetes manifests for AKS

## Run locally

```bash
dotnet run --project src/StudyDeployApi
```

## Build the image

```bash
docker build -t ghcr.io/<owner>/studydeploy-api:latest .
```

## GitHub repository prep

This directory is structured to become its own repository.

- initialize Git: `git init`
- add a GitHub remote that matches the intended image name, ideally `studydeploy-api`
- the GitHub Actions workflow at `.github/workflows/container.yml` builds the app and publishes a GHCR image on pushes to `main`, tags starting with `v`, and manual runs

If the repository name is not `studydeploy-api`, update the image references in the deployment manifests or adjust the workflow image name.

## Deploy to ACA

1. Push the image to your registry.
2. Update `deploy/aca/api.containerapp.yaml` with your subscription, environment, and `ghcr.io` image reference.
3. Deploy the container app:

```bash
az containerapp create --resource-group <rg> --yaml deploy/aca/api.containerapp.yaml
```

## Deploy to AKS

1. Update the image reference in `deploy/aks/api.deployment.yaml`.
2. Copy `deploy/aks/api.secret.sample.yaml` to `deploy/aks/api.secret.yaml` and set a real secret.
3. Apply the manifests:

```bash
kubectl apply -f deploy/aks/api.namespace.yaml
kubectl apply -f deploy/aks/api.configmap.yaml
kubectl apply -f deploy/aks/api.secret.yaml
kubectl apply -f deploy/aks/api.deployment.yaml
kubectl apply -f deploy/aks/api.service.yaml
kubectl apply -f deploy/aks/api.hpa.yaml
```
