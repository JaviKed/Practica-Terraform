output "nginx_config_path" {
  value = "${abspath(path.module)}/nginx.conf"
  description = "The path to the generated nginx configuration file."
}