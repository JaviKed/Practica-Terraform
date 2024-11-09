variable "cache_container_name" {
  type        = string
  description = "The name of the Redis cache container"
}

variable "network_name" {
  type        = string
  description = "The name of the Docker network"
}
