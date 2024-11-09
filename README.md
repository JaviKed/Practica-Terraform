# Practica-Terraform
Deploy de la web de Practica 1 con Terraform añadiendo load balancing y monitorización
# Setup de la práctica
El setup para simular la práctica es el siguiente
## Pre requisitos
Tenere instalado docker y terraform
# Pasos a seguir
### 1. Una vez tenemos instalados los dos softwares necesarios, procedemos a importar a nuestra máquina el repositorio.
### 2. Ejecutamos Docker Desktop y accedemos a la ruta de la carpeta 'Terraform' en el terminal
### 3. Ejecutamos el comando `terraform init` para inicializar terraform y que proceda con la instalación inicial de providers y recursos.
### 4. Aplicar la IAC con el comando `terraform apply -var-file="./prod.tfvars"` para aplicar las variables de entorno que deseemos (cambiar entre dev o prod en el archivo para levantar uno de los entornos)
### 5. Solicitará que introduzcamos una contraseña para Grafana y luego introducir yes para confirmar el apply de terraform.
### 6. Una vez ejecutado observar en docker desktop que todos los contenedores se levantan correctamente y que funcionan de manera esperada.

