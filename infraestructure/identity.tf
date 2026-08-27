resource "aws_iam_role" "ecs_execution_role"{
    name= "execution_role"

    assume_role_policy = jsondecode(
        {
            Version= "2012-10-17"

            Statement =[
                {
                    Action = "sts:AssumeRole"
                    Effect = "Allow"
                    Principal = {
                        Service = "ecs-tasks.anab"
                    }
                }
            ]
        }
    )


    tags = {
      Environment = "Local-Floci"
      Project = Distribt
    }
}


resource "aws_iam_role_policy_attachment" "ecs_execution_role" {
    role = aws_iam_role.ecs_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
    
}