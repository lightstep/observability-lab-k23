terraform {
  required_providers {
    lightstep = {
      source = "lightstep/lightstep"
      version = "1.77.1"
    }
  }
}

provider "lightstep" {
  organization = var.LIGHTSTEP_ORG
  api_key = var.LIGHTSTEP_API_KEY
}

variable "LIGHTSTEP_ORG" {}

variable "LIGHTSTEP_API_KEY" {}

variable "LIGHTSTEP_PROJECT" {}
