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

resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.latest
  ports {
    internal = 3000         # Grafana default internal port
    external = 3000  # External port (e.g., 3000 for Grafana UI)
  }
  volumes {
    # This volume ensures Grafana data is persistent
    host_path      = abspath("${path.module}/data")
    container_path = "/var/lib/grafana"
  }
  env = [
    "GF_SECURITY_ADMIN_USER=${var.admin_user}",
    "GF_SECURITY_ADMIN_PASSWORD=${var.admin_password}"
  ]

  networks_advanced {
    name = var.network_name
  }
}


# Loki Docker container
resource "docker_container" "loki" {
  image = "grafana/loki:latest"
  name  = "loki"
  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 3100
    external = 3100
  }

  # Mount configuration for Loki
  volumes {
    host_path      = abspath("${path.module}/local-config.yaml")
    container_path = "/etc/loki/local-config.yaml"
  }

  volumes {
    host_path      = abspath("${path.module}/loki-data")
    container_path = "/loki"
  }

  # Start Loki with the config file
  command = ["-config.file=/etc/loki/local-config.yaml", "-config.expand-env=true"]
}

# Promtail Docker container for log shipping
resource "docker_container" "promtail" {
  image = "grafana/promtail:latest"
  name  = "promtail"
  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 3101 
    external = 3101  
  }

  env = [
    "LOKI_ADDR = http://loki:3100"  # Loki instance address
  ]
  # Mount config file and log paths
  volumes {
    host_path      = abspath("${path.module}/promtail-config.yaml")
    container_path = "/etc/promtail/config.yaml"
  }

  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers" # Docker logs
  }

  # Start Promtail with the config file
  command = ["-config.file=/etc/promtail/config.yaml"]
  
}