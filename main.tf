terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "vault_too_many_pending_tokens_incident_on_kubernetes" {
  source    = "./modules/vault_too_many_pending_tokens_incident_on_kubernetes"

  providers = {
    shoreline = shoreline
  }
}