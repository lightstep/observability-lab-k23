resource "random_pet" "server" {
  keepers = {
    cluster_name = var.cluster_name
  }
}
resource "digitalocean_kubernetes_cluster" "cluster" {
  name    = "${var.cluster_name}-${random_pet.server.id}"
  region  = var.do_region
  version = "1.26.3-do.0"

  node_pool {
    name       = "default"
    size       = "gd-2vcpu-8gb"
    node_count = var.k8s_node_count
  }
}

provider "helm" {
  kubernetes {
    host  = digitalocean_kubernetes_cluster.cluster.endpoint
    token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
    cluster_ca_certificate = base64decode(
      digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
    )
  }
}
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.cluster.endpoint
  token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
  )
}

output "k8s_cluster_name" {
  value = digitalocean_kubernetes_cluster.cluster.name
}