terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.116"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.15"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.1"
    }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.5"
    # }
  }
}

provider "azurerm" {
  # withut this set, all resource providers will be enabled in the subscription when Terraform first runs
  # security recommendations are to only enable the providers that are required.
  skip_provider_registration = true
  storage_use_azuread        = true

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # This is to handle MCAPS or other policy driven resource creation.
    }

    # some default safety features for Key Vault
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

data "azurerm_subscription" "current" {}
