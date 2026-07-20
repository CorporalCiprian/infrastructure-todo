terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tfstate-todo"
    storage_account_name = "tfstatetodo"
    container_name       = "tfstate-container"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}