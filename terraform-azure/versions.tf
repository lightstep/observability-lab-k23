terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.5.1"
    }
  }
}

# Defaults to CLI authentication
provider "azurerm" {
  features {}
}

