terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.21.0" # Ensure a compatible version
    }
  }
}
provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}

resource "docker_image" "redis" {
  name = "redis:latest"
  keep_locally = true
}

resource "docker_volume" "redisdata" {
  name = "redisdata"
}

resource "docker_container" "cache" {
  count = var.cache_container_name != null ? 1 : 0  # Only create Redis container if name is not null

  name  = var.cache_container_name
  image = "redis:latest"
  ports {
    internal = 6379
    external = 6379
  }
  #Limitación de recursos
  cpu_shares = 512
  memory     = var.redis_memory_limit

  volumes {
    volume_name    = docker_volume.redisdata.name
    container_path = "/data"
  }
  # Configuración de Redis cache
  env = [
    "REDIS_SAVE=900 1", # Save if at least 1 key is modified within 900 seconds
    "REDIS_APPENDONLY=yes", # Enable append-only file mode for durability
    "REDIS_MAXMEMORY=256mb",                # Limita la memoria máxima para Redis
    "REDIS_MAXMEMORY_POLICY=allkeys-lru",   # Política de expulsión para liberar memoria en caso de alta carga
    "REDIS_TCP_KEEPALIVE=60",               # Configuración para conexiones de larga duración
    "REDIS_TIMEOUT=300",   
  ]

  command = ["redis-server", "--bind", "0.0.0.0"]
  networks_advanced {
    name = var.network_name
  }

}

# Add the Redis Commander container
resource "docker_container" "redis_commander" {
  count = var.cache_container_name != null ? 1 : 0
  name  = "redis-commander"
  image = "rediscommander/redis-commander:latest"
  ports {
    internal = 8081
    external = 8081
  }

  env = [
    "REDIS_HOSTS=local:redis:6379",  # Define the Redis host in the format name:host:port
  ]

  # Attach Redis Commander to the same network as the Redis container
  networks_advanced {
    name = var.network_name
  }

  depends_on = [docker_container.cache]  # Ensure Redis starts before Redis Commander
}

resource "docker_container" "redis_exporter" {
  count = var.cache_container_name != null ? 1 : 0
  image = "oliver006/redis_exporter:latest"
  name  = "redis_exporter"
  command = ["-redis.addr", "redis:6379"]
  depends_on = [docker_container.cache]
  ports {
    internal = 9121
    external = 9121
  }
  networks_advanced {
    name = var.network_name
  }
}

