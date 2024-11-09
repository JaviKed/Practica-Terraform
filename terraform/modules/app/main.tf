terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.21.0" # Ensure a compatible version
    }
  }
}
/*provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
}*/

resource "docker_image" "app" {
  name = "my_app_image"
  keep_locally = true
  build {
    path = var.app_path  # Path to your app folder where Dockerfile is located
  }
}



resource "docker_container" "python_app_1" {
  count  = var.num_app_containers
  name   = "app-${count.index + 1}"
  image = docker_image.app.latest

  env = [
    "ENV_TYPE=${var.environment_type}",  # Pass the environment type
    "DB_HOST=${var.db_container_name}",  # Connects to Postgres by name
    "DB_NAME=${var.db_name}",
    "DB_USER=${var.db_user}",
    "DB_PASSWORD=${var.db_password}",
  ]

  ports {
    internal = 5000
    external = 5000 + count.index
  }

  networks_advanced {
    name = var.network_name
  }
  volumes {
    # This volume ensures Grafana data is persistent
    host_path      = abspath("../app")
    container_path = "/app"
  }

}


