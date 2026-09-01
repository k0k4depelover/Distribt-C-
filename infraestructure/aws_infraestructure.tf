resource "aws_cloudwatch_log_group" "ecs_logs"{
  name = "/ecs/distribt-services"
  retention_in_days = 1

  tags ={
    Environment = "Local-Floci"
    Project = "Distribt"
  }
}


resource "aws_lb" "main_alb" {
  name               = "distribt-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_app_subnet_a.id, aws_subnet.public_app_subnet_b.id]

  tags = {
    Name        = "distribt-alb"
    Environment = "Local-Floci"
    Project     = "Distribt"
  }
}


resource "aws_lb_target_group" "api_tg" {
  name        = "distribt-api-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main_vpc.id
  target_type = "ip"


# /health pendiente de implementar
  health_check {
    enabled             = true
    path                = "/health" 
    port                = "8080"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name        = "distribt-api-tg"
    Environment = "Local-Floci"
  }
}



resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.main_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}
