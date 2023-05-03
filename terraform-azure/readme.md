## Azure Terraform

This provisions an AKS cluster using the `az` CLI for authentication.

### 1. Authentication

```
    # Login to an azure account
    az login
```

### 2. Creating a cluster

```
    terraform init
    # Verify terraform plan output looks correct before continuing
    terraform plan
    terraform apply

```

Your cluster name and Azure resource group name will be output after running `terraform apply`.

### 3. Connect to cluster

```
    az aks get-credentials --resource-group YOUR_RESOURCE_GROUP --name YOUR_CLUSTER_NAME
```

Verify kubectl is now configured for the cluster

```
    kubectl cluster-info
```