
locals {
  microservices = [
    # Emails
    "distribt-emails",
    
    # Orders
    "distribt-orders",
    "distribt-orders-consumer",
    
    # Products
    "distribt-products-api-read",
    "distribt-products-api-write",
    "distribt-products-consumer",
    
    # Subscriptions
    "distribt-subscriptions",
    "distribt-subscriptions-consumer"
  ]
}

resource "aws_ecr_repository" "services" {
  for_each             = toset(local.microservices)
  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Environment = "local"
    Project     = "Distribt"
  }
}



resource "aws_ecs_task_definition" "services" {
  for_each = toset(local.microservices)

  family                   = each.value
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = each.value
      image     = "${aws_ecr_repository.services[each.value].repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "ASPNETCORE_ENVIRONMENT", value = "Development" },
        { name = "ASPNETCORE_URLS", value = "http://+:8080" }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/distribt-services"
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


resource "aws_ecs_service" "services" {
  for_each = toset(local.microservices)

  name            = each.value
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.services[each.value].arn
  desired_count   = 1
  launch_type     = "EC2"

  network_configuration {
    subnets         = [aws_subnet.private_app_subnet.id]
    security_groups = [aws_security_group.app_sg.id]
  }
}