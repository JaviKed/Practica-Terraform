variable "app_path" {
  type        = string
  description = "The path to the Python app"
}

variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}
variable "environment_type" {
  type        = string
  description = "The environment type (dev or prod)"
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
variable "db_container_name" {
  type        = string
  description = "The name of the PostgreSQL container"
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