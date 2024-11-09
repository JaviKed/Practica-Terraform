variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}

variable "db_container_name" {
  type        = string
  description = "The name of the PostgreSQL container"
}

variable "db_user" {
  type        = string
  description = "The PostgreSQL user"
  default = "postgres"
}

variable "db_password" {
  type        = string
  description = "The PostgreSQL password"
  default = "postgres"
}

variable "db_name" {
  type        = string
  description = "The PostgreSQL database name"
}

variable "cache_container_name" {
  type        = string
  description = "The name of the Redis cache container"
  default     = null
}

variable "num_app_containers" {
  type        = number
  description = "Number of Python app containers"
}

variable "app_path" {
  type        = string
  description = "The path to the app"
}

variable "environment_type" {
  type        = string
  description = "The environment type (dev or prod)"
}

variable "admin_user" {
  description = "Grafana admin user"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}