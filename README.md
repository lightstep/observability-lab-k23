# Hands-On Observability with OpenTelemetry

This is the repository for the Hands-On Observability with OpenTelemetry Lab,
presented at Knowledge 2023.

## Prerequisites

- A [Lightstep Observability](https://go.lightstep.com/developersignup.html)
  account.
- A DigitalOcean Access Token. You can create one in the
  [API & Security](https://cloud.digitalocean.com/account/api) section of your
  DigitalOcean account.

## Instructions

### Setting up your cluster

1. Fork this repository to your GitHub account.
2. In your fork, create a new CodeSpace.
    - Click the 'Code' button in the top right of the repository.
    - Click the 'CodeSpaces' tab.
    - Click 'Create CodeSpace on main'.
3. Create a new file and name it `.env`.
4. Register for a Lightstep Observability account *or* log in to your existing
   account.
    - In the Lightstep Observability UI, click the 'Project Settings' (Gear) icon
     on the left navigation bar.
    - Click 'Access Tokens' in the left sidebar.
    - Click the copy icon under 'Token' to copy your access token.
    - In the `.env` file you created, add the following line:
      `LIGHTSTEP_ACCESS_TOKEN=<value>`, replacing `<value>` with the access
      token in your clipboard.
    - Return to Lightstep Observability and navigate to 'Account Management >
      API Keys' using the bottom-most icon in the left navigation bar.
    - Create a new API Key with 'Admin' permissions. Give it a descriptive name,
      such as 'knowledge-lab-token'. Click the 'Copy and Close' button on the
      dialog box.
    - In the `.env` file you created, add the following line:
    `LIGHTSTEP_API_KEY=<value>`, replacing `<value>` with the API key in your
    clipboard.
    - Finally, in the `.env` file, add the following line:
    `LIGHTSTEP_ORG=<value>`, replacing `<value>` with the 'Organization Name' in
    your Account Management page. **This value is case-sensitive!**.
5. Add the `DIGITALOCEAN_TOKEN` key and value to `.env`.
6. Create `terraform/values.auto.tfvars` and copy env vars to it. Be sure to
   surround the values in quotation marks.
7. Run `make init`, `make plan`, and `make apply` to create the cluster.

---

Cluster Config

- Configure Helm

``` 
helm repo add jetstack https://charts.jetstack.io
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add lightstep https://lightstep.github.io/otel-collector-charts
helm repo update
```

- Install cert-manager

``` helm install \
     cert-manager jetstack/cert-manager \
     --namespace cert-manager \
     --create-namespace \
     --version v1.8.0 \
     --set installCRDs=true
```

- Install Operator

```
helm install \
     opentelemetry-operator open-telemetry/opentelemetry-operator \
     -n default
```

- Verify Install

```
helm list -A
```

Set Up Cluster Metrics

- kubectl create secret generic otel-collector-secret -n default --from-literal="LS_TOKEN=$LIGHTSTEP_ACCESS_TOKEN"
- helm install kube-otel-stack lightstep/kube-otel-stack -n default --set
  metricsCollector.clusterName=your-cluster-name (from terraform output)
- validate w/kubectl get pods

Set Up Cluster Logging

- kubectl apply -f k8s/log-collector.yaml
// This needs a pass, logs are coming in but we need to do some alignment/processing.

Create Dashboard

- In lightstep, navigate to dashboards. Create pre-built dashboard button.
Collector, Operator, k8s pods, cillium

Deploy Demo

- helm install otel-demo -f k8s/demo-values.yaml open-telemetry/opentelemetry-demo



