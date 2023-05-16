# Hands-On Observability with OpenTelemetry

👋 Welcome to the lab! We're going to get hands-on with setting up a Kubernetes
cluster for observability with OpenTelemetry!

## Prerequisites

- A [ServiceNow Cloud Observability](https://go.lightstep.com/developersignup.html)
  account.
- A DigitalOcean Access Token. You can create one in the
  [API & Security](https://cloud.digitalocean.com/account/api) section of your
  DigitalOcean account.
- A GitHub account.

> __Your instructor will provide you with a Cloud Observability Account and DigitalOcean
> token for this lab.__

## Lab Setup

This lab is designed to teach you the fundamentals of collecting metrics, logs,
and traces from a Kubernetes environment along with how to instrument
applications using OpenTelemetry automatic instrumentation on Kubernetes.

### Set up your Codespace

This lab is designed to be run entirely in your web browser. You'll use GitHub
Codespaces to access an IDE and terminal that will be required to complete the lab.

1. Fork this repository to your GitHub account.
2. In your fork, create a new Codespace.
    - Click the 'Code' button in the top right of the repository.
    - Click the 'Codespaces' tab.
    - Click 'Create Codespace on main'.

### Provisoning a Cloud Observability Account

This lab contains automation to provision a ServiceNow Cloud Observability
user account and project in a pre-existing organization. To set up your
environment, you will need several API keys that will be provided to you
during the lab - your instructor will give you a URL where they can be found.

1. Go to the provided URL and copy the contents of the GitHub gist.
2. Copy and paste this content into your Codespace terminal.
3. In the terminal, run `./scripts/create_user.sh` and follow the on-screen
   instructions.
4. Next run `./scripts/provision_ls.sh` and follow the on-screen instructions.

### Setting up your cluster

Let's start by setting up a fresh Kubernetes cluster. This lab uses
DigitalOcean's managed Kubernetes service, but the same concepts apply to any
K8S cluster -- on AWS, GCP, or Azure there's some extra work to be done around
identity management and storage that's out of scope for this lab.

1. Run `make init` then `make apply` to create the cluster. You
   should see something like this after it completes successfully:

   ``` shell
   digitalocean_kubernetes_cluster.cluster: Creation complete after 4m12s [id=a15869de-4795-45cd-b859-2e8d37744099]
   local_file.kubeconfig: Creating...
   local_file.kubeconfig: Creation complete after 0s [id=856bb072a6a1affb625ac499afd080968c7d78fc]

   Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

   Outputs:

   k8s_cluster_name = "k23-premium-mammal"
   ```

2. Run `export K8S_CLUSTER_NAME=<value>`, where `<value>` is the value of the
   `k8s_cluster_name` output variable in step 7.

### Installing Prerequisites

You now have a running, 3-node Kubernetes cluster. You can run `kubectl get
nodes` to validate that the cluster is operational. Now, you need to install
several pre-requisites.

1. In the terminal, run the following command to add necessary Helm
   repositories:

   ``` shell
   helm repo add jetstack https://charts.jetstack.io
   helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
   helm repo add prometheus https://prometheus-community.github.io/helm-charts
   helm repo add lightstep https://lightstep.github.io/otel-collector-charts
   helm repo update
   ```

2. Run the following command to install `cert-manager`:

   ``` shell
   helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.8.0 --set installCRDs=true
   ```

3. Run the following command to install `opentelemetry-operator`:

   ``` shell
   helm install opentelemetry-operator open-telemetry/opentelemetry-operator -n default --version 0.27.0
   ```

4. Verify the installation of these components by running `helm list -A`. You
   should see output similar to the following:

   ``` shell
   NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
   cert-manager            cert-manager    1               2023-04-26 16:30:31.994524008 +0000 UTC deployed        cert-manager-v1.8.0             v1.8.0     
   opentelemetry-operator  default         1               2023-04-26 16:30:59.478981048 +0000 UTC deployed        opentelemetry-operator-0.27.0   0.75.0   
   ```

### Set up `kube-otel-stack`

Next, you need to install and configure Kubernetes monitoring via the
OpenTelemetry Operator. You can use the `kube-otel-stack` Helm chart to install
monitoring with sensible defaults, including -

- Installation of kube-state-metrics to generate metrics about the state of
  Kubernetes objects.
- Configuration of target allocators to allow for automatic scraping of
  component metrics endpoints.
- Deployment of OpenTelemetry collectors for metrics and tracing collection.

1. Create a secret for your Cloud Observability Access Token:

   ``` shell
   kubectl create secret generic otel-collector-secret -n default --from-literal="LS_TOKEN=$LIGHTSTEP_ACCESS_TOKEN"
   ```

2. Install the `kube-otel-stack` Helm chart:

   ``` shell
   helm install kube-otel-stack lightstep/kube-otel-stack -n default --set metricsCollector.clusterName=$K8S_CLUSTER_NAME --set tracesCollector.clusterName=$K8S_CLUSTER_NAME --set tracesCollector.enabled=true
   ```

3. Verify the installation of this component by running `helm list -A`. The
   output should look similar to the following:

   ``` shell
   NAME                    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
   cert-manager            cert-manager    1               2023-04-26 16:30:31.994524008 +0000 UTC deployed        cert-manager-v1.8.0             v1.8.0     
   kube-otel-stack         default         1               2023-04-26 16:41:07.716305177 +0000 UTC deployed        kube-otel-stack-0.2.11          0.73.0     
   opentelemetry-operator  default         1               2023-04-26 16:30:59.478981048 +0000 UTC deployed        opentelemetry-operator-0.27.0   0.75.0     
   ```

### Add Cluster Logging

Log scraping is not currently available in the `kube-otel-stack`, so we will need to
deploy it independently. A `log-collector.yaml` file has been provided to aid in
this.

1. Run `kubectl apply -f k8s/log-collector.yaml`.

### Deploy the OpenTelemetry Demo Application

Finally, you'll need to deploy a demo application in order to have something to
monitor. The OpenTelemetry Demo application is an e-commerce application fully
instrumented with OpenTelemetry.

1. To deploy the OpenTelemetry Demo application, run the following:

   ``` shell
   helm install otel-demo -f k8s/demo-values.yaml open-telemetry/opentelemetry-demo
   ```

__Your cluster and application is now instrumented for observability!__

## Creating Cloud Observability Dashboards

Now that you have an application, you can use Cloud Observability to create 
dashboards for that application in order to monitor its SLIs and SLOs.

1. Run `make dashboard` to create a service dashboard, then navigate to the 
   dashboards tab in Cloud Observability to view it.

## Using Instrumentation CRDs

The OpenTelemetry operator supports automatic injection of instrumentation via
its Instrumentation Custom Resource Definitions (CRDs).

1. Deploy the `business-metric-service` by running the following command:

   ``` shell
   kubectl apply -f k8s/business-metrics.yaml`
   ```

   _You can find the source code for this service at [this
   link](https://github.com/austinlparker/otel-demo-business-metrics)_

   Note how this service does _not_ have a dependency on the OpenTelemetry SDK, but
   _does_ make calls to the OpenTelemetry API. To enable this instrumentation, and
   connect this service with our existing instrumentation, we need to inject the
   OpenTelemetry Java Agent.

2. Create an Instrumentation CRD by running:

   ``` shell
   kubectl apply -f k8s/instrumentation.yaml
   ```

3. Modify the `k8s/business-metrics.yaml` file as follows:

   ``` yaml
   template:
      metadata:
         labels:
            app: business-metrics-service
         annotations:
            instrumentation.opentelemetry.io/inject-java: "true"
   ```

4. Apply your configuration changes with:

   ```shell
   kubectl apply -f k8s/business-metrics.yaml
   ```

The operator will now inject instrumentation into the pod created by this
deployment, lighting up the OpenTelemetry instrumentation and adding in
automatic instrumentation for Kafka.

## Cleaning Up

After you've completed the lab, please run `./scripts/deprovision_ls.sh` and
`make destroy` to clean up the resources that you created. Quit your Codespace
by opening the command prompt and selecting 'Close Codespace'.
