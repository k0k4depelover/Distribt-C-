# Descripcion de Arquitectura en la Nube

### Patron ECS/ Fargate

* El despliegue de los microservicios se hare utilizando ECS usando el modo de ejecuciòn Fargate, todo orquestado mediante Terraform

* La otra opciòn tomada en cuenta era utilizan EC2, en la que se administra un cluster de servidores EC2, sin embargo para el primer proyecto de cloud 
lo elegido es utilizar Fargate, en la que AWS se encarga de administrar la infraestructura subyaciente, dado que requiere menor control, cero mantenimiento.

* Para lograr desplegar microservicios utilizando Fargate se necesita crear archivos docker multistage para crear contenedores ligeros y publicarlos a ECR el cual es una adaptacion de DockerHub de AWS.

* Posteriormente se definen Task en Terraform apuntando a las imagenes que se subieron a ECR, y ECS que es un cluster donde se agrupan los servicios previamente cargados, ademas se aplican todas las reglas definidas, firewalls, load balancers, roles IAM (Identity Access Managing) y mas reglas definidas.

* Despues se lanzan N tasks en Fargate dentro de la VPC privada 

* Cuando se crean las instancias dentro de la VPC se registra cada task en el Target Group, lo que basicamente significa los puntos de destino del ALB.

* Al agregar estas Task al target group el load balancer ya puede distribuir el trafico, y se pueden centralizar los logs para CloudWatch para todas las salidas de stderr o stdout para una trazabilidad y control de los microservicios.