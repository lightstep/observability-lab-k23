variable "DIGITALOCEAN_TOKEN" {
  default     = ""
  description = "digitalocean pat"
}

variable "do_region" {
  default     = "nyc3"
  description = "digitalocean region"
}

variable "k8s_node_count" {
  default     = 3
  description = "number of k8s nodes"
}

variable "cluster_name" {
  default     = "k23"
  description = "k8s cluster name"
}

variable "kubeconfig_path" {
  description = "The path to save the kubeconfig to"
  default     = "~/.kube/config"
}