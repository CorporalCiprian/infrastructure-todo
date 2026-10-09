#
# Resource Group
#
resource "azurerm_resource_group" "rg_containers" {
  name     = "rg-containers-${var.project_name}-${var.env}"
  location = var.location
}

#
# Environment
#
resource "azurerm_container_app_environment" "cae_todo" {
  name                     = "cae-${var.project_name}-${var.env}"
  resource_group_name      = azurerm_resource_group.rg_containers.name
  location                 = azurerm_resource_group.rg_containers.location
  infrastructure_subnet_id = module.subnets.subnet_ids["container_apps"]
  public_network_access    = "Enabled"
  lifecycle {
    ignore_changes = [workload_profile, log_analytics_workspace_id]
  }
}

#
# Container apps
#
resource "azurerm_container_app" "ca_backend" {
  name                         = "ca-backend-${var.project_name}-${var.env}"
  container_app_environment_id = azurerm_container_app_environment.cae_todo.id
  resource_group_name          = azurerm_resource_group.rg_containers.name
  revision_mode                = "Single"

  secret {
    key_vault_secret_id = azurerm_key_vault_secret.connection_string_db.id
    name                = azurerm_key_vault_secret.connection_string_db.name
    identity            = "/subscriptions/63daad41-14a4-47e4-ac30-399d12e79b3e/resourceGroups/managed-identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/actions-runner"
  }
  template {
    min_replicas = 1
    container {
      name   = "backend-container"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
      env {
        name        = "DATABASE_URL"
        secret_name = azurerm_key_vault_secret.connection_string_db.name
      }
    }
  }
  ingress {
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    cors {
      allowed_origins = [ "https://${azurerm_container_app.ca_frontend.ingress[0].fqdn}", ]
      allowed_headers = ["*"]
      allowed_methods = ["*"]
    }
    transport        = "auto"
    external_enabled = true
    target_port      = 8001
  }

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/63daad41-14a4-47e4-ac30-399d12e79b3e/resourceGroups/managed-identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/actions-runner"]
  }

  lifecycle {
    ignore_changes = [workload_profile_name, registry, secret, template]
  }
}

resource "azurerm_container_app" "ca_frontend" {
  name                         = "ca-frontend-${var.project_name}-${var.env}"
  container_app_environment_id = azurerm_container_app_environment.cae_todo.id
  resource_group_name          = azurerm_resource_group.rg_containers.name
  revision_mode                = "Single"

  ingress {
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
    transport        = "auto"
    external_enabled = true
    target_port      = 8000
  }

  template {
    min_replicas = 1
    container {
      name   = "frontend-container"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }

  lifecycle {
    ignore_changes = [workload_profile_name, registry, secret, template]
  }
}

#
# Registry
#
resource "azurerm_container_registry" "cr_todo" {
  name                = "cr${var.project_name}${var.env}"
  resource_group_name = azurerm_resource_group.rg_containers.name
  location            = azurerm_resource_group.rg_containers.location
  sku                 = "Premium"

  public_network_access_enabled = false
  identity {
    type = "SystemAssigned"
  }

  admin_enabled = true
}