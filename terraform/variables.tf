variable "location" {
  type    = string
  default = "francecentral"
}

variable "resource_group_name" {
  type    = string
  default = "rg-todo-app"
}

variable "vault_name" {
  type        = string
  description = "The name of the key vault to be created. The value will be randomly generated if blank."
  default     = ""
}

variable "sku_name" {
  type        = string
  description = "The SKU of the vault to be created."
  default     = "standard"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The sku_name must be one of the following: standard, premium."
  }
}

variable "key_permissions" {
  type        = list(string)
  description = "List of key permissions."
  default     = ["List", "Create", "Delete", "Get", "Purge", "Recover", "Update", "GetRotationPolicy", "SetRotationPolicy"]
}

variable "secret_permissions" {
  type        = list(string)
  description = "List of secret permissions."
  default     = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

variable "connection_string_value" {
  type    = string
  description = "connection string to the psql db"
  default = ""
}

variable "db_password" {
  type = string
  description = "default value of db pass"
  default = ""
}

variable "allowed_origins" {
  type = string
  default = "https://func-todo-frontend.azurewebsites.net"
}

variable "asp_name" {
  type = string
  default = ""
}

variable "connection_string_name" {
  type = string
  default = ""
}

variable "db_pass_name" {
  type = string
  default = ""
}

variable "kv_name" {
  type = string
  default = ""
}

variable "backend_name" {
  type = string
  default = ""
}

variable "frontend_name" {
  type = string
  default = ""
}

variable "st_backend_name" {
  type = string
  default = ""
}

variable "st_frontend_name" {
  type = string
  default = ""
}

variable "pg_server_name" {
  type = string
  default = ""
}

variable "admin_db_login" {
  type = string
  default = ""
}

variable "pg_db_name" {
  type = string
  default = ""
}