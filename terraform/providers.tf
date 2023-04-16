terraform {
  required_providers {
    lightstep = {
      source = "lightstep/lightstep"
      version = "~> 1.70.6"
    }
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">=2.3.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">=2.5.0"
    }
  }
}

provider "digitalocean" {
  token = var.DIGITALOCEAN_TOKEN
}

 provider "lightstep" {
   api_key         = var.LIGHTSTEP_API_KEY
   organization    = var.LIGHTSTEP_ORG
 }