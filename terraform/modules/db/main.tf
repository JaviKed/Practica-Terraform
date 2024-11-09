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

resource "docker_image" "postgres" {
  name = "postgres:latest"
  keep_locally = true
}

resource "docker_volume" "pgdata" {
  name = var.environment_type == "dev" ? "pgdata_dev" : "pgdata_prod"
}

resource "docker_container" "alchemy_postgres" {
  image = docker_image.postgres.latest
  name  = var.db_container_name

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}"
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    host_path      = abspath("${path.module}/init.sql")
    container_path = "/docker-entrypoint-initdb.d/init.sql"
  }

  volumes {
    volume_name      = docker_volume.pgdata.name  # Reference the persistent volume by name
    container_path = "/var/lib/postgresql/data" # PostgreSQL data directory
  }

  networks_advanced {
    name = var.network_name
  }
  
}
resource "docker_container" "adminer" {
  image = "adminer:latest"  # Use the latest Adminer image
  name  = "adminer"

  # Set Adminer to use the same network as your app and database containers
  networks_advanced {
    name = var.network_name
  }

  # Expose Adminer on port 8080
  ports {
    internal = 8080
    external = 8082  # You can change the external port if necessary
  }

  # Environment variables for connecting Adminer to PostgreSQL
  env = [
    "ADMINER_DEFAULT_SERVER=${var.db_container_name}"  # Reference the database host name
  ]

  depends_on = [
    docker_container.alchemy_postgres  # Ensure Adminer starts after the database
  ]
}

resource "docker_container" "postgres_exporter" {
  image = "wrouesnel/postgres_exporter:latest"
  name  = "postgres_exporter"
  env = [
    "DATA_SOURCE_NAME=postgresql://postgres:postgres@${var.db_container_name}:5432/${var.db_container_name}?sslmode=disable"
  ]
  depends_on = [docker_container.alchemy_postgres]
  ports {
    internal = 9187
    external = 9187
  }
  networks_advanced {
    name = var.network_name
  }
}
