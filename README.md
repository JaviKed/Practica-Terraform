# Practica-Terraform
Deploy de la web de Practica 1 con Terraform añadiendo load balancing y monitorización
# Setup de la práctica
El setup para simular la práctica es el siguiente
## Pre requisitos
Tenere instalado docker y terraform
# Pasos a seguir
### 1. Una vez tenemos instalados los dos softwares necesarios, procedemos a importar a nuestra máquina el repositorio.
### 2. Ejecutamos Docker Desktop y accedemos a la ruta de la carpeta 'Terraform' en el terminal
> **🚨 ATENCIÓN 🚨**  
> ## Cabe mencionar que se ha de revisar los archivos main.tf y cambiar en provider docker host su valor según nuestro SO Para Windows: `"npipe:////.//pipe//docker_engine"` para UNIX: `"unix:///var/run/docker.sock"`
> ## También es imporante para evitar errores comprobar que la opcion `Use containerd for pulling and storing images` en docker desktop esté desactivada

### 3. Ejecutamos el comando `terraform init` para inicializar terraform y que proceda con la instalación inicial de providers y recursos.
### 4. Aplicar la IAC con el comando `terraform apply -var-file="./prod.tfvars"` para aplicar las variables de entorno que deseemos (cambiar entre dev o prod en el archivo para levantar uno de los entornos)
### 5. Solicitará que introduzcamos una contraseña para Grafana y luego introducir yes para confirmar el apply de terraform.
### 6. Una vez ejecutado observar en docker desktop que todos los contenedores se levantan correctamente y que funcionan de manera esperada.

# Arquitectura del proyecto
La arquitectura del proyecto la vamos a explicar por módulos generados por terraform y la app de flask aparte
## Root
### - Archivo main.tf para llamar a todos los modulos
### - Archivos tfvars para las variables de entorno
### - Archivo variables.tf para declarar las variables que va a utilizar la infraestructura
### - Directorio de módulos
Dentro de la carpeta modulos encontramos los creados en el archivo main.tf
## Modulo logs
### - Carpeta data que contiene la db de grafana para guardar la dashboard y las alertas
### - Main.tf que realiza deploy del contenedor de grafana, loki (para log management) y promtail (para el scrape de logs)
### - Archivos yaml de configuracioón para promtail (hace scrap de los containers de docker) y loki (gestion de los logs obtenidos de promtail)
## Modulo App
### - Main.tf que levanta 3 replicas del contenedor de la app de Flask
### - Variables.tf para recibir las variables de entorno desde root
## Modulo db
### - Main.tf que levanta los contenedores de postgres para la DB, adminer (UI para gestionar la DB) y postgres_exporter (scrap de metricas de la DB). Además crea un volumen de persistencia para cada tipo de env.
### - Variables.tf para recibir las variables desde root de entorno (crea DB de dev o prod segun el tfvars)
### - init.sql para crear la tabla vacia en caso de que no haya ninguna en la base de datos.
## Modulo cache
### - Main.tf que levanta los contenedores de redis para la cache, RedisCommander (UI para gestionar la cache) y redis_exporter (scrap de metricas de la cache).
### - Variables.tf para recibir las variables desde root de entorno (crea cache en prod unicamente)
## Modulo nginx
### - Main.tf que levanta los contenedores de nginx para balanceo de trafico (en este caso, round robin), nginx_exporter (scrap de metricas de nginx) y prometheus (para mostrar las graficas de las metricas exportadas)
### - Archivo tpl de template para poder realizar el archivo config.nginx dinámico según la cantidad de containers de app creados.
### - Archivo yml de configuración para prometheus asignandole los jobs de cache, db y nginx
### - Variables.tf para recibir las variables desde root de entorno (recibe la cantidad de containers app creados para realizar el config.nignx)
##  FLASK APP
Fuera de la carpeta de terraform tenemos la carpeta de la app de flask creada que utilizaran los contenedores de app.
### App.py que contiene el codigo de la app, adpatado para obtener las variables desde terraform.
### El funcionamiento de la app es el mismo que el de la práctica anterior con docker-compose con un cambio, ahora obtiene su IP y la muestra para poder comprobar que el balancing se realiza de manera correcta por nginx

# Test utilizados
Los tests realizados sobre está práctica son sobretodo sobre nginx (app) y grafana (logs).
## NGINX Y APP
### Actualización de `localhost:8080` para comprobar que la ip va cambiando, en este caso, siguiendo un patrón de round robin.
### Stop command `docker stop <nombre_contenedor_servicio>` sobre los servicios para comprobar que los cambios en el html son correctos.
### Start command `docker start <nombre_contenedor_servicio>` para comprobar la persistencia de los datos.
### Borrado de volumenes para comprobar la inicialización de correcta de la base de datos.

## LOGS
Como en el modulo de logs esta la carpeta de data de grafana, ya tenemos las data source, alertas y dasboards para poder realizar las pruebas sobre la monitorización.
### Observar en el dashboard que los datos se obtienen correctamente, en este caso el estado up de los 3 servicios (nginx, db y cache), los logs de todos los contenedores y las request a la aplicación.
### Apagar los contenedores de los servicios y ver como se obtienen los logs de error y se activan las alertas que comunicarán que alguno de los servicios está parado (en este caso la alerta esta configurada para enviarse por mail a un generico).
