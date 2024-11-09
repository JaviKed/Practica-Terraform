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

variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}