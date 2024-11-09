terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.21.0"
    }
  }
}



# Create a Docker network
resource "docker_network" "app_network" {
  name = var.network_name
}

# Call the PostgreSQL module
module "db" {
  source             = "./modules/db"
  db_container_name  = var.db_container_name
  db_user            = var.db_user
  db_password        = var.db_password
  db_name            = var.db_name
  environment_type   = var.environment_type
  network_name       = docker_network.app_network.name
}

# Call the Redis module
module "cache" {
  source             = "./modules/cache"
  cache_container_name = var.cache_container_name
  network_name       = docker_network.app_network.name
}

# Call the Python app module
module "app" {
  source             = "./modules/app"
  num_app_containers = var.num_app_containers
  app_path           = var.app_path
  network_name       = docker_network.app_network.name
  environment_type   = var.environment_type
  db_container_name  = var.db_container_name
  db_name            = var.db_name
  cache_container_name = var.cache_container_name
  depends_on = [
    module.db,
    module.cache
  ]
}

module "grafana" {
  source         = "./modules/logs"
  admin_user     = var.admin_user
  admin_password = var.admin_password
  network_name   = var.network_name
  depends_on = [
    docker_network.app_network
  ]
}

module "nginx"{
  source             = "./modules/nginx"
  network_name       = docker_network.app_network.name
  environment_type   = var.environment_type
  start = module.app.app_creada
  depends_on = [
    module.db,
    module.cache
  ]
}