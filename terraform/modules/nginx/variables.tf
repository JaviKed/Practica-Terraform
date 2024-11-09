variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}

variable "start" {
  type  =     number 
  description = "Dependency on app module"
}

variable "environment_type" {
  type        = string
  description = "The environment type (dev or prod)"
}

locals {
  app_servers = var.environment_type == "prod" ? ["app-1:5000", "app-2:5000", "app-3:5000"] : ["app-1:5000", "app-2:5000"]
}