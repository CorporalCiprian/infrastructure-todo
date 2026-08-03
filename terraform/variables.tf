variable "location" {
  type    = string
  default = "francecentral"
}

# variable "func_asp_sku_name" {
#   type        = string
#   description = "The SKU of the vault to be created."
#   default     = "standard"
#   validation {
#     condition     = contains(["standard", "premium"], var.sku_name)
#     error_message = "The sku_name must be one of the following: standard, premium."
#   }
# }

variable "env" {
  type        = string
  description = ""
}

variable "project_name" {
  type = string
  default = ""
}

#TODO: app settings object for env specific vars