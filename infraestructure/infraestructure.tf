resource "aws_launch_template" "ecs_nodes" {
  name_prefix = "ecs-nodes-"
  image_id = "ami-abcde113123433" # Simulado
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_role_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups =  [aws_ecs_cluster.main.name]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "ECS_CLUSTER = ${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config"
    EOF
  )

  tags = {
    Name = "ecs-node-template"
  }
}


resource "aws_iam_role" "ecs_node_role" {
  name = "ecs_node_role"
  assume_role_policy = jsonencode({
    Statement =[{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "ec2.amazonaws.com"
            }
        }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_node_role_policy" {
  role = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  }
  resource "aws_iam_instance_profile" "ec2_role_profile"{
    name= "ecs-node-profile"
    role = aws_iam_role.ecs_node_role.name
  
}


resource "aws_autoscaling_group" "ecs_asg" {
    name_prefix = "ecs-asg-"
    vpc_zone_identifier = [aws_subnet.private_app_subnet.id]
    min_size = 1
    max_size = 3
    desired_capacity = 1

    launch_template {
      id = aws_launch_template.ecs_nodes.id
      version = "$latest"
    }

    tag {
      key = "AmazonECSManaged"
      value = "true"
      propagate_at_launch = true
    }

}


resource "aws_ecs_capacity_provider" "ecs_cp" {

    name = "distrib-capacity-provider"
    auto_scaling_group_provider {
      auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

      managed_scaling {
        maximum_scaling_step_size = 1000
        minimum_scaling_step_size = 1
        status = "ENABLED"
        target_capacity = 100
      }
    }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name]

  default_capacity_provider_strategy {
    base = 1
    weight = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_cp.name
  }
}