terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-todo"
    storage_account_name = "tfstatetodo"
    container_name       = "tfstate-container"
    key                  = "terraform.tfstate"
    tenant_id            = "c1b556a4-d724-4480-b79c-c5ac6bd2686d"
    subscription_id      = "a62b0e0a-3c52-4f04-b56b-9c72ceb3b143"
  }
}

provider "azurerm" {
  features {}
}