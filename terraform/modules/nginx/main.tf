terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.21.0" # Ensure a compatible version
    }
  }
}



data "template_file" "nginx_config" {
  template = file("${path.module}/nginx.conf.tpl")
  vars = {
    app_servers = join("\n", [for server in local.app_servers : "server ${server};"])
  }
}

resource "local_file" "nginx_conf" {
  content  = data.template_file.nginx_config.rendered
  filename = "${abspath(path.module)}/nginx.conf"
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = "nginx:latest"
  ports {
    internal = 80
    external = 8080  # Expose NGINX load balancer on port 80
  }

  volumes {
    host_path      = abspath("${path.module}/nginx.conf")  # Path to the custom NGINX config
    container_path = "/etc/nginx/nginx.conf"               # NGINX expects the config file here
  }

  networks_advanced {
    name = var.network_name
  }
}

resource "docker_image" "nginx_exporter" {
  name = "nginx/nginx-prometheus-exporter:latest"
}

resource "docker_container" "nginx_exporter" {
  name  = "nginx_exporter"
  image = docker_image.nginx_exporter.latest
  
  ports {
    internal = 9113
    external = 9113
  }

  command = ["-nginx.scrape-uri=http://nginx:8080/stub_status"]

  depends_on = [docker_container.nginx]

  networks_advanced {
    name = var.network_name
  }
  restart    = "unless-stopped"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = abspath("${path.module}/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }

  networks_advanced {
    name = var.network_name
  }
}


