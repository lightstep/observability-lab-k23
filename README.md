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
3. Create a new terminal (Cmd+Shift+P, create new terminal)
4. Register for a Lightstep Observability account *or* log in to your existing
   account.
    - In the Lightstep Observability UI, click the 'Project Settings' (Gear) icon
     on the left navigation bar.
    - Click 'Access Tokens' in the left sidebar.
    - Click the copy icon under 'Token' to copy your access token.
    - In your codespace, run `export LIGHTSTEP_ACCESS_TOKEN=<token>` where
      `<token>` is the token in your clipboard.
5. Find the `DIGITALOCEAN_TOKEN` at the provided URL.
6. Create `terraform/values.auto.tfvars` and add `DIGITALOCEAN_TOKEN` to it.
7. Run `make init`, `make plan`, and `make apply` to create the cluster. You
   should see something like this after it completes successfully:
```
digitalocean_kubernetes_cluster.cluster: Creation complete after 4m12s [id=a15869de-4795-45cd-b859-2e8d37744099]
local_file.kubeconfig: Creating...
local_file.kubeconfig: Creation complete after 0s [id=856bb072a6a1affb625ac499afd080968c7d78fc]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

k8s_cluster_name = "k23-premium-mammal"
```
8. Run `export K8S_CLUSTER_NAME=<value>`, where `<value>` is the value of the
   `k8s_cluster_name` output variable in step 7.

### Installing Prerequisites

1. In the terminal, run the following command to add necessary Helm
   repositories:
```
helm repo add jetstack https://charts.jetstack.io
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm repo add lightstep https://lightstep.github.io/otel-collector-charts
helm repo update
```
2. Run the following command to install `cert-manager`:
```
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
```
3. Run the following command to install `opentelemetry-operator`:
```
helm install opentelemetry-operator open-telemetry/opentelemetry-operator -n default
```
4. Verify the installation of these components by running `helm list -A`. You
   should see output similar to the following:
```
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
cert-manager            cert-manager    1               2023-04-26 16:30:31.994524008 +0000 UTC deployed        cert-manager-v1.8.0             v1.8.0     
opentelemetry-operator  default         1               2023-04-26 16:30:59.478981048 +0000 UTC deployed        opentelemetry-operator-0.27.0   0.75.0   
```

### Set up `kube-otel-stack`

1. Create a secret for your Lightstep Access Token:
```
kubectl create secret generic otel-collector-secret -n default --from-literal="LS_TOKEN=$LIGHTSTEP_ACCESS_TOKEN"
```
2. Install the `kube-otel-stack` Helm chart:
```
helm install kube-otel-stack lightstep/kube-otel-stack -n default --set metricsCollector.clusterName=$K8S_CLUSTER_NAME --set tracesCollector.clusterName=$K8S_CLUSTER_NAME --set tracesCollector.enabled=true
```
3. Verify the installation of this component by running `helm list -A`. The
   output should look similar to the following:
```
NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
cert-manager            cert-manager    1               2023-04-26 16:30:31.994524008 +0000 UTC deployed        cert-manager-v1.8.0             v1.8.0     
kube-otel-stack         default         1               2023-04-26 16:41:07.716305177 +0000 UTC deployed        kube-otel-stack-0.2.11          0.73.0     
opentelemetry-operator  default         1               2023-04-26 16:30:59.478981048 +0000 UTC deployed        opentelemetry-operator-0.27.0   0.75.0     
```

### Add Cluster Logging

Logging is not currently baked into the `kube-otel-stack`, so we will need to
deploy it independently. A `log-collector.yaml` file has been provided to aid in
this.

1. Run `kubectl apply -f k8s/log-collector.yaml`.

### Deploy the OpenTelemetry Demo Application

1. To deploy the OpenTelemetry Demo application, run the following:
```
helm install otel-demo -f k8s/demo-values.yaml open-telemetry/opentelemetry-demo
```

**Your cluster and application is now instrumented for observability!**

## Using Instrumentation CRDs

The OpenTelemetry operator supports automatic injection of instrumentation via
its Instrumentation Custom Resource Definitions (CRDs).

1. Deploy the `business-metric-service` by running `kubectl apply -f
   k8s/business-metrics.yaml`
_You can find the source code for this service at [this
link](https://github.com/austinlparker/otel-demo-business-metrics)_

Note how this service does _not_ have a dependency on the OpenTelemetry SDK, but
_does_ make calls to the OpenTelemetry API. To enable this instrumentation, and
connect this service with our existing instrumentation, we need to inject the
OpenTelemetry Java Agent.

2. Create an Instrumentation CRD by running `kubectl apply -f
   k8s/instrumentation.yaml`
3. Modify the `k8s/business-metrics.yaml` file as follows:
``` yaml
  template:
    metadata:
      labels:
        app: business-metrics-service
      annotations:
        instrumentation.opentelemetry.io/inject-java: "true"
```
4. Run `kubectl apply -f k8s/business-metrics.yaml`.

The operator will now inject instrumentation into the pod created by this
deployment, lighting up the OpenTelemetry instrumentation and adding in
automatic instrumentation for Kafka.