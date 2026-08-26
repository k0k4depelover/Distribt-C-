terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  # Configuración para Floci o en Raspberry Pi
  endpoints {
    ec2 = "http://localhost:4566"
    ecr = "http://localhost:4566"
    ecs = "http://localhost:4566"
  }
}


resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "vpc-distribuida-lab"
    Environment = "Local-Floci"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "igw-lab"
  }
}


resource "aws_subnet" "public_app_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-public-app-1a"
  }
}

resource "aws_subnet" "private_app_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada-app-1a"
  }
}

resource "aws_subnet" "private_db_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada-db-1a"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-publica"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "rt-privada"
  }
}

resource "aws_route_table_association" "public_app_assoc" {
  subnet_id = aws_subnet.public_app_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "app_assoc" {
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "db_assoc" {
  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  depends_on = [ aws_internet_gateway.igw ]

  tags = {
    Name = "eip-nat-gateway"
  }
}


resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_app_subnet.id

  tags = {
    Name = "main-nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route" "private_nat_router" {
  route_table_id = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}


resource "aws_security_group" "alb_sg" {
  name        = "alb-publico"
  description = "Permite trafico HTTP/HTTPS desde el exterior"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP desde Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde Internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-alb-publico"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "microservicios"
  description = "Permite trafico SOLO desde el Load Balancer Publico"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "Trafico de la app desde el ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Comunicacion entre microservicios"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    self        = true # Permite comunicarse entre si en el puerto 8080
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "microservicios"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "bases-de-datos"
  description = "Permite trafico SOLO desde los microservicios"
  vpc_id      = aws_vpc.main_vpc.id

  dynamic "ingress" {
    for_each = [
      { port = 1514, proto = "tcp", desc = "Graylog Syslog TCP" },
      { port = 1514, proto = "udp", desc = "Graylog Syslog UDP" },
      { port = 3000, proto = "tcp", desc = "Grafana" },
      { port = 3306, proto = "tcp", desc = "MySQL" },
      { port = 4317, proto = "tcp", desc = "OTel Collector gRPC" },
      { port = 5672, proto = "tcp", desc = "RabbitMQ AMQP" },
      { port = 8200, proto = "tcp", desc = "HashiCorp Vault" },
      { port = 8400, proto = "tcp", desc = "Consul RPC" },
      { port = 8500, proto = "tcp", desc = "Consul HTTP" },
      { port = 8600, proto = "tcp", desc = "Consul DNS TCP" },
      { port = 8600, proto = "udp", desc = "Consul DNS UDP" },
      { port = 8888, proto = "tcp", desc = "OTel Collector Metrics" },
      { port = 8889, proto = "tcp", desc = "OTel Collector Prometheus exporter" },
      { port = 9000, proto = "tcp", desc = "Graylog Web Interface" },
      { port = 9090, proto = "tcp", desc = "Prometheus" },
      { port = 9411, proto = "tcp", desc = "Zipkin" },
      { port = 12201, proto = "tcp", desc = "Graylog GELF TCP" },
      { port = 12201, proto = "udp", desc = "Graylog GELF UDP" },
      { port = 15672, proto = "tcp", desc = "RabbitMQ Management" },
      { port = 27017, proto = "tcp", desc = "MongoDB" }
    ]
    content {
      description     = ingress.value.desc
      from_port       = ingress.value.port
      to_port         = ingress.value.port
      protocol        = ingress.value.proto
      security_groups = [aws_security_group.app_sg.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bases-de-datos"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "distribt-ecs-cluster"

  tags = {
    Environment = "local"
    Project     = "Distribt"
  }
}