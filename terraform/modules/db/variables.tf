variable "db_container_name" {
  type        = string
  description = "The name of the PostgreSQL container"
}

variable "db_user" {
  type        = string
  description = "The PostgreSQL user"
}

variable "db_password" {
  type        = string
  description = "The PostgreSQL password"
}

variable "db_name" {
  type        = string
  description = "The PostgreSQL database name"
}

variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}
variable "environment_type" {
  type        = string
  description = "The environment type (dev or prod)"
}