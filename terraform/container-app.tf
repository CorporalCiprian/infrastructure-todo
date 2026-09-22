resource "azurerm_resource_group" "rg_containers" {
  name = "rg-containers-${var.project_name}-${var.env}"
  location = var.location
}

resource "azurerm_container_app_environment" "cae_todo" {
  name = "cae-${var.project_name}-${var.env}"
  resource_group_name = azurerm_resource_group.rg_containers.name
  location = azurerm_resource_group.rg_containers.location
  infrastructure_subnet_id = module.subnets.subnet_ids["container_apps"]
  public_network_access = "Disabled"
  lifecycle {
    ignore_changes = [ workload_profile, log_analytics_workspace_id ]
  }
}

resource "azurerm_container_app" "ca_backend" {
  name = "ca-backend-${var.project_name}-${var.env}"
  container_app_environment_id = azurerm_container_app_environment.cae_todo.id
  resource_group_name = azurerm_resource_group.rg_containers.name
  revision_mode = "Single"

  secret {
    key_vault_secret_id = azurerm_key_vault_secret.connection_string_db.id
    name = azurerm_key_vault_secret.connection_string_db.name
    identity = "System"
  }
  template {
    container {
      name = "backend-container"
      image = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu = 0.25
      memory = "0.5Gi"
      env {
        name = "ALLOWED_ORIGINS"
        value = "https://${azurerm_container_app.ca_frontend.latest_revision_fqdn}/src"
      }
    }
  }

  registry {
    identity = "system"
    server = azurerm_container_registry.cr_todo.login_server
  }

  ingress {
    traffic_weight {
    percentage = 100
    latest_revision = true
    }
    transport = "auto"
    external_enabled = true
    target_port = 8001
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [ workload_profile_name , template, secret ]
  }
}

resource "azurerm_container_registry" "cr_todo" {
  name = "cr${var.project_name}${var.env}"
  resource_group_name = azurerm_resource_group.rg_containers.name
  location = azurerm_resource_group.rg_containers.location
  sku = "Premium"

  identity {
    type = "SystemAssigned"
  }

  admin_enabled = true
}

resource "azurerm_container_app" "ca_frontend" {
  name = "ca-frontend-${var.project_name}-${var.env}"
  container_app_environment_id = azurerm_container_app_environment.cae_todo.id
  resource_group_name = azurerm_resource_group.rg_containers.name
  revision_mode = "Single"
  
  ingress {
    traffic_weight {
    percentage = 100
    latest_revision = true
    }
    transport = "auto"
    external_enabled = true
    target_port = 8000
  }
  
  template {
    container {
      name = "frontend-container"
      image = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu = 0.25
      memory = "0.5Gi"
    }
  }
  
  lifecycle {
    ignore_changes = [ workload_profile_name , registry, template, secret ]
  }
}