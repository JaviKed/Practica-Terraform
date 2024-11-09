variable "cache_container_name" {
  type        = string
  description = "The name of the Redis cache container"
}

variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}

variable "redis_memory_limit" {
  default = "512536870912"  # Ajusta según los recursos disponibles en tu máquina local
}